//
//  ObservationFactory.swift
//  Allie
//
//  Created by Waqar Malik on 3/12/21.
//

import Foundation
import HealthKit
import ModelsR4

class ObservationFactory: BaseFactory, ResourceFactoryProtocol {
	func resource<T>(from object: HKObject) throws -> T {
		guard T.self is ModelsR4.Observation.Type else {
			throw ConversionError.incorrectTypeForFactory
		}

		let value = try observation(from: object) as? T
		return value!
	}

	func observation(from object: HKObject) throws -> ModelsR4.Observation {
		guard let sample = object as? HKSample else {
			// The given type is not currently supported.
			throw ConversionError.unsupportedType(identifier: String(describing: HKObject.self))
		}

		let status = FHIRPrimitive<ObservationStatus>(.final)
		let code = try codeableConcept(objectType: sample.sampleType)

		let observation = ModelsR4.Observation(code: code, status: status)

		if let quantitySample = sample as? HKQuantitySample {
			// The sample is a quantity sample - create a valueQuantity (conversion data provided in the Config).
			observation.value = .quantity(try valueQuantity(sample: quantitySample))
		} else if let correlation = sample as? HKCorrelation {
			// The sample is a correlation - create components with the appropriate values (conversion data provided in the Config).
			observation.component = try component(correlation: correlation)
		} else {
			// The sample type is not currently supported.
			throw ConversionError.unsupportedType(identifier: sample.sampleType.identifier)
		}

		// Add the HealthKit Identifier
		observation.identifier = [Self.identifier(system: BaseFactory.healthKitIdentifierSystemKey, value: sample.uuid.uuidString)]

		// Set the effective date
		let effective = try self.effective(sample: sample)
		if let dateTime = effective as? ModelsR4.DateTime {
			observation.effective = .dateTime(FHIRPrimitive<DateTime>(dateTime))
		} else if let period = effective as? ModelsR4.Period {
			observation.effective = .period(period)
		}

		return observation
	}

	func observation(from values: [Double], identifier: String, date: Date) throws -> ModelsR4.Observation {
		guard !values.isEmpty else {
			throw ConversionError.requiredConversionValueMissing(key: identifier)
		}

		guard let codeableConcept = configuarion[code: identifier] else {
			throw ConversionError.conversionNotDefinedForType(identifier: identifier)
		}
		let status = FHIRPrimitive<ObservationStatus>(.final)
		let observation = ModelsR4.Observation(code: codeableConcept, status: status)
		if values.count == 1, let value = values.first {
			observation.value = .quantity(try valueQuantity(value: value, identifier: identifier))
		} else {
			observation.component = try component(values: values, identifier: identifier)
		}

		return observation
	}

	func codeableConcept(objectType: HKObjectType) throws -> ModelsR4.CodeableConcept {
		guard let codeableConcept = configuarion[code: objectType.identifier] else {
			throw ConversionError.conversionNotDefinedForType(identifier: objectType.identifier)
		}

		return codeableConcept
	}

	func valueQuantity(sample: HKQuantitySample) throws -> ModelsR4.Quantity {
		guard let quantity = configuarion[quantity: sample.sampleType.identifier] else {
			throw ConversionError.conversionNotDefinedForType(identifier: sample.sampleType.identifier)
		}
		guard let unitString = quantity.unit?.value?.string else {
			throw ConversionError.conversionNotDefinedForType(identifier: sample.sampleType.identifier)
		}
		let unit = HKUnit(from: unitString)
		let value = sample.quantity.doubleValue(for: unit)
		return try valueQuantity(value: value, identifier: sample.sampleType.identifier)
	}

	func valueQuantity(value: Double, identifier: String) throws -> ModelsR4.Quantity {
		guard let quantity = configuarion[quantity: identifier] else {
			throw ConversionError.conversionNotDefinedForType(identifier: identifier)
		}
		let fhirValue = FHIRPrimitive<FHIRDecimal>(floatLiteral: value)
		quantity.value = fhirValue
		return quantity
	}

	func component(correlation: HKCorrelation) throws -> [ModelsR4.ObservationComponent] {
		var components: [ModelsR4.ObservationComponent] = []

		for sample in correlation.objects {
			if let quantitySample = sample as? HKQuantitySample {
				let codeableConcept = try self.codeableConcept(objectType: quantitySample.sampleType)
				let component = ObservationComponent(code: codeableConcept)
				component.value = .quantity(try valueQuantity(sample: quantitySample))
				components.append(component)
			} else {
				throw ConversionError.conversionNotDefinedForType(identifier: sample.sampleType.identifier)
			}
		}

		return components
	}

	func component(values: [Double], identifier: String) throws -> [ModelsR4.ObservationComponent] {
		guard !values.isEmpty else {
			throw ConversionError.requiredConversionValueMissing(key: identifier)
		}
		return try values.compactMap { value in
			guard let codeableConcept = configuarion[code: identifier] else {
				return nil
			}
			let component = ObservationComponent(code: codeableConcept)
			component.value = .quantity(try valueQuantity(value: value, identifier: identifier))
			return component
		}
	}

	func effective(sample: HKSample) throws -> Any {
		let timeZoneString = sample.metadata?[HKMetadataKeyTimeZone] as? String

		if sample.startDate == sample.endDate, let dateTime = dateTime(date: sample.startDate, timeZoneString: timeZoneString) {
			return dateTime
		}

		if let start = dateTime(date: sample.startDate, timeZoneString: timeZoneString), let end = dateTime(date: sample.endDate, timeZoneString: timeZoneString) {
			let period = ModelsR4.Period()
			period.start = ModelsR4.FHIRPrimitive<DateTime>(start)
			period.end = ModelsR4.FHIRPrimitive<DateTime>(end)

			return period
		}

		throw ConversionError.dateConversionError
	}

	var configuarion: ObservationsConfig
	required init(configName: String? = nil, bundle: Foundation.Bundle = Bundle.main) throws {
		self.configuarion = try ObservationsConfig()
		super.init()
	}
}
