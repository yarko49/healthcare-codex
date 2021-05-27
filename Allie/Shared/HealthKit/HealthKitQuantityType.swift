//
//  HealthKitQuantityType.swift
//  Allie
//

import HealthKit
import UIKit

enum HealthKitQuantityType: String, CaseIterable {
	case weight = "Weight"
	case activity = "Activity"
	case bloodPressure = "Blood Pressure"
	case restingHeartRate = "Resting Heart Rate"
	case heartRate = "Heart Rate"

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
		}
	}

	var color: UIColor {
		switch self {
		case .activity:
			return UIColor.activityBackground
		case .bloodPressure:
			return UIColor.bloodPressure ?? .red
		case .heartRate:
			return UIColor.heartRate ?? .systemPink
		case .restingHeartRate:
			return UIColor.restingHeartRate ?? .systemPink
		case .weight:
			return UIColor.weightBackground
		}
	}

	var image: UIImage {
		switch self {
		case .activity:
			return UIImage(named: "icon-activity") ?? UIImage()
		case .bloodPressure:
			return UIImage(named: "icon-blood-pressure") ?? UIImage()
		case .heartRate:
			return UIImage(named: "icon-heart-rate") ?? UIImage()
		case .restingHeartRate:
			return UIImage(named: "icon-heart-rate") ?? UIImage()
		case .weight:
			return UIImage(named: "icon-weight") ?? UIImage()
		}
	}

	var unit: String {
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
			return .pound()
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
		}
	}
}
