//
//  HealthKitDataType.swift
//  Allie
//
//  Created by Waqar Malik on 2/20/21.
//

import Foundation
import HealthKit
import ModelsR4

enum HealthKitDataType: String, CaseIterable, CustomStringConvertible {
	case bodyMass
	case heartRate
	case restingHeartRate
	case stepCount
	case bloodPressure
	case bloodGlucose
	case insulinDelivery

	var description: String {
		rawValue
	}

	var unit: HKUnit {
		switch self {
		case .bodyMass:
			return HKUnit.pound()
		case .heartRate:
			return HKUnit.count().unitDivided(by: HKUnit.minute())
		case .restingHeartRate:
			return HKUnit.count().unitDivided(by: HKUnit.minute())
		case .stepCount:
			return HKUnit.count()
		case .bloodPressure:
			return HKUnit.millimeterOfMercury()
		case .bloodGlucose:
			return HKUnit.gram().unitDivided(by: HKUnit.liter())
		case .insulinDelivery:
			return HKUnit(from: "mIU/ml")
		}
	}

	var code: ModelsR4.CodeableConcept {
		switch self {
		case .bodyMass:
			return ModelsR4.CodeableConcept.bodyMass
		case .heartRate:
			return ModelsR4.CodeableConcept.heartRate
		case .restingHeartRate:
			return ModelsR4.CodeableConcept.restingHeartRate
		case .stepCount:
			return ModelsR4.CodeableConcept.stepCount
		case .bloodPressure:
			return ModelsR4.CodeableConcept.bloodPressure
		case .bloodGlucose:
			return ModelsR4.CodeableConcept.bloodGlucose
		case .insulinDelivery:
			return ModelsR4.CodeableConcept.insulinDelivery
		}
	}

	var quantityType: [HKQuantityType?] {
		switch self {
		case .bodyMass:
			return [HKObjectType.quantityType(forIdentifier: .bodyMass)]
		case .heartRate:
			return [HKObjectType.quantityType(forIdentifier: .heartRate)]
		case .restingHeartRate:
			return [HKObjectType.quantityType(forIdentifier: .restingHeartRate)]
		case .stepCount:
			return [HKObjectType.quantityType(forIdentifier: .stepCount)]
		case .bloodPressure:
			return [HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic), HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)]
		case .bloodGlucose:
			return [HKObjectType.quantityType(forIdentifier: .bloodGlucose)]
		case .insulinDelivery:
			return [HKObjectType.quantityType(forIdentifier: .insulinDelivery)]
		}
	}

	var searchParameter: SearchParameter {
		SearchParameter(sort: "-date", count: 1, code: code.coding?.first?.code?.value?.string)
	}
}
