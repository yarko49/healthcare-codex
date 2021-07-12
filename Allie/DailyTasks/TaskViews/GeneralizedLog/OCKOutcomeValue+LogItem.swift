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
		let title = "\(kind?.title ?? "") \(value) " + HealthKitDataType.insulinDelivery.unit.unitString
		return title
	}

	var bloodGlucoseItem: String? {
		let kind = HKBloodGlucoseMealTime(kind: self.kind ?? "")
		let value = integerValue ?? 0
		let title = "\(kind?.title ?? NSLocalizedString("FASTING", comment: "Fasting")) \(value) " + HealthKitDataType.bloodGlucose.unit.unitString
		return title
	}
}
