//
//  ObservationsConfig.swift
//  Allie
//
//  Created by Waqar Malik on 3/12/21.
//

import Foundation
import ModelsR4

class ObservationsConfig {
	class var configURL: URL? {
		Bundle.main.url(forResource: "ObservationsConfig", withExtension: "json")
	}

	private struct ObservationConfig: Codable {
		var code: CodeableConcept
		var valueQuantity: Quantity
	}

	private var observations: [String: ObservationConfig] = [:]

	convenience init() throws {
		guard let url = ObservationsConfig.configURL else {
			throw ConfigurationError.defaultConfigurationNotFound
		}
		try self.init(url: url)
	}

	convenience init(url: URL) throws {
		let data = try Data(contentsOf: url)
		try self.init(data: data)
	}

	required init(data: Data) throws {
		let decoded = try JSONDecoder().decode([String: ObservationConfig].self, from: data)
		self.observations = decoded
	}

	subscript(code key: String) -> ModelsR4.CodeableConcept? {
		get {
			observations[key]?.code
		}
		set {
			guard let value = newValue else {
				observations.removeValue(forKey: key)
				return
			}
			if var observation = observations[key] {
				observation.code = value
				observations[key] = observation
			}
		}
	}

	subscript(quantity key: String) -> Quantity? {
		get {
			observations[key]?.valueQuantity
		}
		set {
			guard let value = newValue else {
				observations.removeValue(forKey: key)
				return
			}
			if var observation = observations[key] {
				observation.valueQuantity = value
				observations[key] = observation
			}
		}
	}
}
