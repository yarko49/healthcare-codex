//
//  HealthKitQuantityType.swift
//  Allie
//

import HealthKit
import UIKit

// Deprecated HealthKitDataType
public enum HealthKitQuantityType: String, CaseIterable {
	case weight
	case activity
	case bloodPressure
	case restingHeartRate
	case heartRate
	case bloodGlucose

	public var displayTitle: String {
		switch self {
		case .weight:
			return NSLocalizedString("WEIGHT", comment: "Weight")
		case .activity:
			return NSLocalizedString("ACTIVITY", comment: "Activity")
		case .bloodPressure:
			return NSLocalizedString("BLOOD_PRESSURE", comment: "Blood Pressure")
		case .restingHeartRate:
			return NSLocalizedString("RESTING_HEART_RATE", comment: "Resting Heart Rate")
		case .heartRate:
			return NSLocalizedString("HEART_RATE", comment: "Heart Rate")
		case .bloodGlucose:
			return NSLocalizedString("BLOOD_GLUCOSE", comment: "Blood Glucose")
		}
	}

	public var healthKitQuantityType: HKQuantityType? {
		switch self {
		case .activity:
			return HKObjectType.quantityType(forIdentifier: .stepCount)
		case .weight:
			return HKObjectType.quantityType(forIdentifier: .bodyMass)
		case .restingHeartRate:
			return HKObjectType.quantityType(forIdentifier: .restingHeartRate)
		case .heartRate:
			return HKObjectType.quantityType(forIdentifier: .heartRate)
		case .bloodGlucose:
			return HKObjectType.quantityType(forIdentifier: .bloodGlucose)
		default:
			return nil
		}
	}

	public var healthKitQuantityTypeIdentifiers: [HKQuantityTypeIdentifier] {
		switch self {
		case .weight:
			return [.bodyMass]
		case .activity:
			return [.stepCount]
		case .bloodPressure:
			return [.bloodPressureDiastolic, .bloodPressureSystolic]
		case .heartRate:
			return [.heartRate]
		case .restingHeartRate:
			return [.restingHeartRate]
		case .bloodGlucose:
			return [.bloodGlucose]
		}
	}

	public var image: UIImage? {
		switch self {
		case .activity:
			return UIImage(named: "icon-activity")
		case .bloodPressure:
			return UIImage(named: "icon-blood-pressure")
		case .heartRate:
			return UIImage(named: "icon-heart-rate")
		case .restingHeartRate:
			return UIImage(named: "icon-heart-rate")
		case .weight:
			return UIImage(named: "icon-weight")
		case .bloodGlucose:
			return UIImage(named: "icon-blood-glucose")
		}
	}

	public var unitString: String {
		switch self {
		case .activity:
			return "steps"
		case .bloodPressure:
			return "mmHG"
		case .heartRate:
			return "bpm"
		case .restingHeartRate:
			return "bpm"
		case .weight:
			return "lbs"
		case .bloodGlucose:
			return "mg/dL"
		}
	}

	public var hkUnit: HKUnit {
		switch self {
		case .activity:
			return .count()
		case .bloodPressure:
			return .millimeterOfMercury()
		case .heartRate:
			return HKUnit.count().unitDivided(by: .minute())
		case .restingHeartRate:
			return HKUnit.count().unitDivided(by: .minute())
		case .weight:
			return HKUnit.pound()
		case .bloodGlucose:
			return HKUnit.gramUnit(with: .milli).unitDivided(by: HKUnit.literUnit(with: .deci))
		}
	}
}
