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
	var insulinLogItem: String? {
		let kind = HKInsulinDeliveryReason(kind: self.kind ?? "")
		let value = doubleValue ?? 0.0
		let title = "\(kind?.title ?? "") \(value) " + (units ?? "")
		return title
	}

	var bloodGlucoseItem: String? {
		let mealTime = CHBloodGlucoseMealTime(kind: kind ?? "")
		let value = integerValue ?? 0
		let title = "\(mealTime?.title ?? "") \(value) " + (units ?? "")
		return title
	}

	var valueItem: String? {
		let value = integerValue ?? Int(doubleValue ?? 0)
		let title = "\(value) " + (units ?? "")
		return title
	}
}
