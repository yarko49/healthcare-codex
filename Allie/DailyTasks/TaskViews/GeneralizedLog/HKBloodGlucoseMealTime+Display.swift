//
//  HKBloodGlucoseMealTime+Display.swift
//  Allie
//
//  Created by Waqar Malik on 7/11/21.
//

import Foundation
import HealthKit

extension HKBloodGlucoseMealTime {
	init?(kind: String) {
		if kind == "preprandial" {
			self = .preprandial
		} else if kind == "postprandial" {
			self = .postprandial
		} else {
			return nil
		}
	}

	var title: String {
		switch self {
		case .preprandial:
			return NSLocalizedString("BEFORE_MEAL", comment: "Before Meal")
		case .postprandial:
			return NSLocalizedString("AFTER_MEAL", comment: "After Meal")
		@unknown default:
			return NSLocalizedString("FASTING", comment: "Fasting")
		}
	}

	var kind: String {
		switch self {
		case .preprandial:
			return "preprandial"
		case .postprandial:
			return "postprandial"
		@unknown default:
			return "noprandial"
		}
	}
}
