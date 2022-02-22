//
//  HealthKitDataType.swift
//  Allie
//
//  Created by Waqar Malik on 2/20/21.
//

import HealthKit
import ModelsR4
import UIKit

enum HealthKitDataType: String, CaseIterable, Hashable {
	case bodyMass
	case heartRate
	case restingHeartRate
	case stepCount
	case bloodPressure
	case bloodGlucose
	case insulinDelivery

	var displayTitle: String {
		switch self {
		case .bodyMass:
			return NSLocalizedString("WEIGHT", comment: "Weight")
		case .heartRate:
			return NSLocalizedString("HEART_RATE", comment: "Heart Rate")
		case .restingHeartRate:
			return NSLocalizedString("RESTING_HEART_RATE", comment: "Resting Heart Rate")
		case .stepCount:
			return NSLocalizedString("STEP_COUNT", comment: "Step Count")
		case .bloodPressure:
			return NSLocalizedString("BLOOD_PRESSURE", comment: "Blood Pressure")
		case .bloodGlucose:
			return NSLocalizedString("BLOOD_GLUCOSE", comment: "Blood Glucose")
		case .insulinDelivery:
			return NSLocalizedString("INSULIN", comment: "Insulin")
		}
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
			return HKUnit.gramUnit(with: .milli).unitDivided(by: HKUnit.literUnit(with: .deci))
		case .insulinDelivery:
			return HKUnit.internationalUnit()
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

	var quantityTypeIdentifiers: [HKQuantityTypeIdentifier] {
		switch self {
		case .bodyMass:
			return [.bodyMass]
		case .heartRate:
			return [.heartRate]
		case .restingHeartRate:
			return [.restingHeartRate]
		case .stepCount:
			return [.stepCount]
		case .bloodPressure:
			return [.bloodPressureDiastolic, .bloodPressureSystolic]
		case .bloodGlucose:
			return [.bloodGlucose]
		case .insulinDelivery:
			return [.insulinDelivery]
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

	var image: UIImage? {
		switch self {
		case .bodyMass:
			return UIImage(named: "icon-weight")
		case .heartRate:
			return UIImage(named: "icon-heart-rate")
		case .restingHeartRate:
			return UIImage(named: "icon-heart-rate")
		case .stepCount:
			return UIImage(named: "icon-activity")
		case .bloodPressure:
			return UIImage(named: "icon-blood-pressure")
		case .bloodGlucose:
			return UIImage(named: "icon-blood-glucose")
		case .insulinDelivery:
			return UIImage(named: "icon-insulin")
		}
	}

	var searchParameter: SearchParameter {
		SearchParameter(sort: "-date", count: 1, code: code.coding?.first?.code?.value?.string)
	}
}
