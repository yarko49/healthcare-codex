//
//  BGMMealTime.swift
//  Allie
//
//  Created by Waqar Malik on 7/27/21.
//

import Foundation
import HealthKit

enum BGMMealTime: Int {
	case undefined
	case preprandial
	case postprandial
	case fasting
	case casual
	case bedtime
}

extension BGMMealTime: CustomStringConvertible {
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

	var mealTime: HKBloodGlucoseMealTime? {
		switch self {
		case .postprandial:
			return .postprandial
		case .preprandial:
			return .preprandial
		default:
			return nil
		}
	}
}
