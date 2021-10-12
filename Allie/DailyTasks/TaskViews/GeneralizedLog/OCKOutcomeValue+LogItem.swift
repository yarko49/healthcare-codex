//
//  OCKOutcome+LogItem.swift
//  Allie
//
//  Created by Waqar Malik on 7/11/21.
//

import CareKitStore
import Foundation
import HealthKit

extension OCKOutcomeValue {
	var formattedValue: String? {
		if let integerValue = integerValue {
			return "\(integerValue) " + (units ?? "")
		} else if let doubleValue = doubleValue {
			return "\(doubleValue) " + (units ?? "")
		} else {
			return nil
		}
	}

	var insulinReason: String? {
		HKInsulinDeliveryReason(kind: kind ?? "")?.title
	}

	var bloodGlucoseMealTime: String? {
		let mealTime = CHBloodGlucoseMealTime(kind: kind ?? "")
		if mealTime == .unknown {
			return nil
		}
		return mealTime?.title
	}
}
