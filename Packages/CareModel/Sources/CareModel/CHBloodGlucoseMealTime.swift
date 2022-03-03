//
//  BloodGlucoseMealTime.swift
//  Allie
//
//  Created by Waqar Malik on 7/27/21.
//

import Foundation
import HealthKit

public let CHMetadataKeyBloodGlucoseMealTime = "CHBloodGlucoseMealTime"

public enum CHBloodGlucoseMealTime: Int, Hashable, CaseIterable {
	case unknown
	case preprandial
	case postprandial
	case fasting
	case casual
	case bedtime

	public init?(kind: String) {
		let lower = kind.lowercased()
		if lower == "unknown" {
			self = .unknown
		} else if lower == "preprandial" {
			self = .preprandial
		} else if lower == "postprandial" {
			self = .postprandial
		} else if lower == "fasting" {
			self = .fasting
		} else if lower == "casual" {
			self = .casual
		} else if lower == "bedtime" {
			self = .bedtime
		} else {
			return nil
		}
	}
}

extension CHBloodGlucoseMealTime: CustomStringConvertible {
	public var description: String {
		switch self {
		case .unknown:
			return "Unknown"
		case .preprandial:
			return "Preprandial"
		case .postprandial:
			return "Postprandial"
		case .fasting:
			return "Fasting"
		case .casual:
			return "Casual"
		case .bedtime:
			return "Bedtime"
		}
	}
}

public extension CHBloodGlucoseMealTime {
	var kind: String {
		description.lowercased()
	}

	var title: String {
		switch self {
		case .unknown:
			return NSLocalizedString("MEAL_TIME_UNKNOWN", comment: "Unknown")
		case .preprandial:
			return NSLocalizedString("MEAL_TIME_BEFORE_MEAL", comment: "Before Meal")
		case .postprandial:
			return NSLocalizedString("MEAL_TIME_AFTER_MEAL", comment: "After Meal")
		case .fasting:
			return NSLocalizedString("MEAL_TIME_FASTING", comment: "Fasting")
		case .casual:
			return NSLocalizedString("MEAL_TIME_CASUAL", comment: "Casual")
		case .bedtime:
			return NSLocalizedString("MEAL_TIME_BEDTIME", comment: "Bedtime")
		}
	}

	var valueRange: ClosedRange<Int> {
		0 ... 999
	}
}
