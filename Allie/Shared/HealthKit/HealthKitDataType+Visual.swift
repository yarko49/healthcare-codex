//
//  HealthKitDataType+Visual.swift
//  Allie
//
//  Created by Waqar Malik on 3/1/22.
//

import CareModel
import ModelsR4
import UIKit

extension HealthKitDataType {
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

	var color: UIColor {
		switch self {
		case .bodyMass:
			return .activity
		case .heartRate:
			return .heartRate
		case .restingHeartRate:
			return .restingHeartRate
		case .stepCount:
			return .activity
		case .bloodPressure:
			return .bloodPressure
		case .bloodGlucose:
			return .bloodGlucose
		case .insulinDelivery:
			return .insulin
		}
	}

	var searchParameter: SearchParameter {
		SearchParameter(sort: "-date", count: 1, code: code.coding?.first?.code?.value?.string)
	}
}
