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
		let numberFormatter = NumberFormatter.valueFormatter
		if let integerValue = integerValue {
			let number = NSNumber(value: integerValue)
			let value = numberFormatter.string(from: number) ?? "\(integerValue)"
			return value + " " + (units ?? "")
		} else if let doubleValue = doubleValue {
			let number = NSNumber(value: doubleValue)
			let value = numberFormatter.string(from: number) ?? "\(doubleValue)"
			return value + " " + (units ?? "")
		} else {
			return nil
		}
	}

	var insulinDeliveryReason: HKInsulinDeliveryReason? {
		HKInsulinDeliveryReason(kind: kind ?? "")
	}

	var insulinReasonTitle: String? {
		insulinDeliveryReason?.title
	}

	var bloodGlucoseMealTimeTitle: String? {
		let mealTime = bloodGlucoseMealTime
		if mealTime == .unknown {
			return nil
		}
		return mealTime?.title
	}

	var bloodGlucoseMealTime: CHBloodGlucoseMealTime? {
		CHBloodGlucoseMealTime(kind: kind ?? "")
	}

	var symptomTitle: String? {
		guard let kind = kind, let severityType = CHOutcomeValueSeverityType(rawValue: kind) else {
			return nil
		}

		return (stringValue ?? "") + " " + severityType.title
	}
}
