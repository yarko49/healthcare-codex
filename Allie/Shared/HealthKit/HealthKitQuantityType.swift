//
//  HealthKitQuantityType.swift
//  Allie
//

import HealthKit
import UIKit

// Deprecated HealthKitDataType
enum HealthKitQuantityType: String, CaseIterable {
	case weight
	case activity
	case bloodPressure
	case restingHeartRate
	case heartRate
	case bloodGlucose

	var displayTitle: String {
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

	var healthKitQuantityType: HKQuantityType? {
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

	var healthKitQuantityTypeIdentifiers: [HKQuantityTypeIdentifier] {
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

	var color: UIColor {
		switch self {
		case .activity:
			return UIColor.activity
		case .bloodPressure:
			return UIColor.bloodPressure
		case .heartRate:
			return UIColor.heartRate
		case .restingHeartRate:
			return UIColor.restingHeartRate
		case .weight:
			return UIColor.weight
		case .bloodGlucose:
			return UIColor.bloodGlucose
		}
	}

	var image: UIImage? {
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

	var unitString: String {
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

	var hkUnit: HKUnit {
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

	func status(for values: [Double]) -> (UIColor, String) {
		guard !values.isEmpty else { return (.clear, "") }
		switch self {
		case .weight:
			guard let weightValue = values.first else { return (.clear, "") }
			if weightValue < 110.0 {
				return (.statusRed, String.belowNormal)
			} else if weightValue < 180, weightValue >= 110 {
				return (.statusGreen, String.healthy)
			} else if weightValue < 220 {
				return (.statusYellow, String.heavy)
			} else {
				return (.statusRed, String.obese)
			}
		case .activity:
			guard let stepCount = values.first else { return (.clear, "") }
			if stepCount < 500 {
				return (.statusRed, String.belowNormal)
			} else if stepCount >= 500, stepCount < 5000 {
				return (.statusYellow, String.onTrack)
			} else {
				return (.statusGreen, String.healthy)
			}

		case .bloodPressure:
			guard let systolic = values.first, let diastolic = values.last else { return (.clear, "") }
			if systolic < 120 && diastolic < 80 {
				return (.statusGreen, String.normal)
			} else if 120 ... 129 ~= systolic && diastolic < 80 {
				return (.statusYellow, String.bpElevated)
			} else if 130 ... 139 ~= systolic || 80 ... 89 ~= diastolic {
				return (.statusOrange, String.bpHigh)
			} else if 140 ... 179 ~= systolic || diastolic >= 90 {
				return (.statusRed, String.bpHigh2)
			} else if systolic >= 180 || diastolic > 12 {
				return (.statusDeepRed, String.bpCrisis)
			} else {
				return (.clear, "")
			}
		case .restingHeartRate:
			guard let restingHR = values.first else { return (.clear, "") }
			if restingHR < 30 || restingHR > 90 {
				return (.statusOrange, String.notNormal)
			} else {
				return (.statusGreen, String.healthy)
			}
		case .heartRate:
			guard let heartRate = values.first else { return (.clear, "") }
			if heartRate < 50 || heartRate > 110 {
				return (.statusOrange, String.notNormal)
			} else {
				return (.statusGreen, String.healthy)
			}
		case .bloodGlucose:
			guard let bloodGlucose = values.first else { return (.clear, "") }
			if bloodGlucose > 250 {
				return (.statusOrange, NSLocalizedString("VERY_HIGH", comment: "Very High"))
			} else if bloodGlucose > 180 {
				return (.statusYellow, NSLocalizedString("HIGH", comment: "High"))
			} else if bloodGlucose >= 70 {
				return (.statusGreen, String.normal)
			} else if bloodGlucose >= 54 {
				return (.statusRed, NSLocalizedString("LOW", comment: "Low"))
			} else {
				return (.statusDeepRed, NSLocalizedString("VERY_LOW", comment: "Very Low"))
			}
		}
	}
}
