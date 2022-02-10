//
//  BaseFactory.swift
//  Allie
//
//  Created by Waqar Malik on 3/12/21.
//

import Foundation
import HealthKit
import ModelsR4

public protocol ResourceFactoryProtocol {
	static var healthKitIdentifierSystemKey: String { get }
	func resource<T>(from object: HKObject) throws -> T
}

public typealias FHIRJSON = [String: Any]

public class BaseFactory {
	enum Constants {
		static let defaultObservationFactoryConfigurationFileName = "ObservationsConfig"
		static let configFileExtension = ".json"
		static let healthAppBundleId = "com.apple.health"
		static let hkObjectSystemValue = "com.apple.health.hkobject"
		static let systemKey = "system"
		static let valueKey = "value"
		static let valueQuantityKey = "valueQuantity"
		static let unitKey = "unit"
		static let codeKey = "code"
	}

	public static let healthKitIdentifierSystemKey = Constants.healthAppBundleId

	var conversionMap: [String: [String: FHIRJSON]] = [:]
	let dateFormatter = ISO8601DateFormatter()

	public init() {}

	public func dateTime(date: Date, timeZoneString: String?) -> ModelsR4.DateTime? {
		date.r4FHIRDateTime(timeZoneString: timeZoneString)
	}

	public static func identifier(system: String, value: String) -> ModelsR4.Identifier {
		let identifier = ModelsR4.Identifier()
		identifier.system = FHIRPrimitive<FHIRURI>(stringLiteral: system)
		identifier.value = FHIRPrimitive<FHIRString>(stringLiteral: value)
		return identifier
	}

	public static func identifier(type: ModelsR4.CodeableConcept, value: String) -> ModelsR4.Identifier {
		let identifier = ModelsR4.Identifier()
		identifier.type = type
		identifier.value = FHIRPrimitive<FHIRString>(stringLiteral: value)
		return identifier
	}

	public static func coding(system: String, code: String, display: String? = nil) -> ModelsR4.Coding {
		let coding = ModelsR4.Coding()
		coding.system = FHIRPrimitive<FHIRURI>(stringLiteral: system)
		coding.code = FHIRPrimitive<FHIRString>(stringLiteral: code)
		if let display = display {
			coding.display = FHIRPrimitive<FHIRString>(stringLiteral: display)
		}
		return coding
	}
}

public extension BaseFactory {
	func loadConfiguration(configName: String?, bundle: Foundation.Bundle) throws {
		if var configName = configName {
			// Remove the .json extension if included.
			if configName.lowercased().hasSuffix(Constants.configFileExtension) {
				configName.removeLast(Constants.configFileExtension.count)
			}

			// Ensure the name string isn't empty.
			guard !configName.isEmpty else {
				throw ConfigurationError.configurationNotFound
			}

			// Get the filepath for the config.
			if let path = bundle.path(forResource: configName, ofType: Constants.configFileExtension) {
				do {
					// Initialize a data object with the contents of the file.
					let data = try Data(contentsOf: URL(fileURLWithPath: path))
					try loadConfiguration(data: data)

				} catch {
					// The configuration was not formatted correctly.
					throw ConfigurationError.invalidConfiguration
				}

			} else {
				// The confiuration could not be found in the given bundle for the given name.
				throw ConfigurationError.configurationNotFound
			}
		}
	}

	func loadConfiguration(data: Data) throws {
		if let dictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: [String: FHIRJSON]] {
			for (key, value) in dictionary {
				if var existingValue = conversionMap[key] {
					// There is default conversion data - merge.
					existingValue.merge(value, uniquingKeysWith: { _, new in new })
				} else {
					// No default conversion data - add to conversion map.
					conversionMap[key] = value
				}
			}
		}
	}
}
