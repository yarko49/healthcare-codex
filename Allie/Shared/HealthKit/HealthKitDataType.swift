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
		}
	}

	var code1: ModelsR4.CodeableConcept {
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
		}
	}

	var code: MedicalCode {
		switch self {
		case .bodyMass:
			return MedicalCode.bodyWeight
		case .heartRate:
			return MedicalCode.heartRate
		case .restingHeartRate:
			return MedicalCode.restingHeartRate
		case .stepCount:
			return MedicalCode.stepsCount
		case .bloodPressure:
			return MedicalCode.bloodPressure
		case .bloodGlucose:
			return MedicalCode.bloodGlucose
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
		}
	}

	var searchParameter: SearchParameter {
		switch self {
		case .bodyMass:
			return SearchParameter(sort: "-date", count: 1, code: MedicalCode.bodyWeight.coding?.first?.code)
		case .stepCount:
			return SearchParameter(sort: "-date", count: 1, code: MedicalCode.stepsCount.coding?.first?.code)
		case .bloodPressure:
			return SearchParameter(sort: "-date", count: 1, code: MedicalCode.bloodPressure.coding?.first?.code)
		case .restingHeartRate:
			return SearchParameter(sort: "-date", count: 1, code: MedicalCode.restingHeartRate.coding?.first?.code)
		case .heartRate:
			return SearchParameter(sort: "-date", count: 1, code: MedicalCode.heartRate.coding?.first?.code)
		case .bloodGlucose:
			return SearchParameter(sort: "-date", count: 1, code: MedicalCode.bloodGlucose.coding?.first?.code)
		}
	}
}
