//
//  BloodGlucoseMealTime.swift
//  Allie
//
//  Created by Waqar Malik on 7/27/21.
//

import Foundation
import HealthKit

let CHMetadataKeyBloodGlucoseMealTime = "CHBloodGlucoseMealTime"

enum CHBloodGlucoseMealTime: Int, Hashable, CaseIterable {
	case undefined
	case preprandial
	case postprandial
	case fasting
	case casual
	case bedtime

	init?(kind: String) {
		if kind == "undefined" {
			self = .undefined
		} else if kind == "preprandial" {
			self = .preprandial
		} else if kind == "postprandial" {
			self = .postprandial
		} else if kind == "fasting" {
			self = .fasting
		} else if kind == "casual" {
			self = .casual
		} else if kind == "bedtime" {
			self = .bedtime
		} else {
			return nil
		}
	}
}

extension CHBloodGlucoseMealTime: CustomStringConvertible {
	var description: String {
		switch self {
		case .undefined:
			return "Undefined"
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

extension CHBloodGlucoseMealTime {
	var kind: String {
		description.lowercased()
	}

	var title: String {
		switch self {
		case .undefined:
			return NSLocalizedString("MEAL_TIME_UNDEFINED", comment: "Undefined")
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
}
