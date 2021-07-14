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
		let kind = HKBloodGlucoseMealTime(kind: self.kind ?? "")
		let value = integerValue ?? 0
		let title = "\(kind?.title ?? NSLocalizedString("FASTING", comment: "Fasting")) \(value) " + (units ?? "")
		return title
	}

	var valueItem: String? {
		let value = doubleValue ?? 0
		let title = "\(value) " + (units ?? "")
		return title
	}
}
