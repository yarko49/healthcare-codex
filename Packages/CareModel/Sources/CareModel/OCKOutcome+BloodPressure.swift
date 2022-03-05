//
//  OCKOutcome+BloodPressure.swift
//  Allie
//
//  Created by Onseen on 12/18/21.
//

import CareKitStore
import Foundation
import HealthKit

/// Some types of measurements for outcome may have multiple values.
/// For example, blood-pressure will consist of 2 values - systolic, diastolic
/// `Record` will represent each measurement
public extension OCKAnyOutcome {
	var valuesCountPerRecord: Int {
		guard let quantityIdentifier = values.first?.quantityIdentifier else {
			return 1
		}

		if quantityIdentifier == HKQuantityTypeIdentifier.bloodPressureSystolic.rawValue || quantityIdentifier == HKQuantityTypeIdentifier.bloodPressureDiastolic.rawValue {
			return 2
		}
		return 1
	}

	var recordsCount: Int {
		values.count / valuesCountPerRecord
	}

	/// Returns the array of outcomeValues for certain record
	///
	/// - Parameters:
	///   - index: Indicates the certain record among the array of records
	func getValuesForRecord(at index: Int) -> [OCKOutcomeValue] {
		if index >= recordsCount {
			return []
		}

		var record: [OCKOutcomeValue] = []
		let startIndex = index * valuesCountPerRecord
		let endIndex = startIndex + valuesCountPerRecord
		for subIndex in startIndex ..< endIndex {
			record.append(values[subIndex])
		}
		return record
	}
}
