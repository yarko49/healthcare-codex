//
//  HKDiscreteQuantitySample+BloodGlucose.swift
//  Allie
//
//  Created by Waqar Malik on 7/11/21.
//

import Foundation
import HealthKit

extension HKDiscreteQuantitySample {
	convenience init(bloodGlucose level: Double, startDate: Date, mealTime: CHBloodGlucoseMealTime) {
		let quantity = HKQuantity(unit: HealthKitDataType.bloodGlucose.unit, doubleValue: level)
		var metadata: [String: Any] = [:]
		metadata[HKMetadataKeyTimeZone] = TimeZone.current.identifier
		metadata[HKMetadataKeyWasUserEntered] = true
		metadata[CHMetadataKeyUpdatedDate] = Date()
		metadata[CHMetadataKeyBloodGlucoseMealTime] = NSNumber(value: mealTime.rawValue)
		if mealTime == .postprandial || mealTime == .preprandial {
			metadata[HKMetadataKeyBloodGlucoseMealTime] = NSNumber(value: mealTime.rawValue)
		}
		let quantityType = HKQuantityType.quantityType(forIdentifier: .bloodGlucose)
		self.init(type: quantityType!, quantity: quantity, start: startDate, end: startDate, device: HKDevice.local(), metadata: metadata)
	}
}
