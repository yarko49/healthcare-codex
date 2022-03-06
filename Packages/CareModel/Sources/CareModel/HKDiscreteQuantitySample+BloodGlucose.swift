//
//  HKDiscreteQuantitySample+BloodGlucose.swift
//  Allie
//
//  Created by Waqar Malik on 7/11/21.
//

import Foundation
import HealthKit

public extension HKDiscreteQuantitySample {
	convenience init(bloodGlucose level: Double, startDate: Date, mealTime: CHBloodGlucoseMealTime, metadata: [String: Any]?) {
		let quantity = HKQuantity(unit: HealthKitDataType.bloodGlucose.unit, doubleValue: level)
		var newMetadata: [String: Any] = metadata ?? [:]
		newMetadata[HKMetadataKeyTimeZone] = TimeZone.current.identifier
		newMetadata[HKMetadataKeyWasUserEntered] = true
		newMetadata[CHMetadataKeyUpdatedDate] = Date()
		newMetadata[CHMetadataKeyBloodGlucoseMealTime] = NSNumber(value: mealTime.rawValue)
		if mealTime == .postprandial || mealTime == .preprandial {
			newMetadata[HKMetadataKeyBloodGlucoseMealTime] = NSNumber(value: mealTime.rawValue)
		}
		let quantityType = HKQuantityType.quantityType(forIdentifier: .bloodGlucose)
		self.init(type: quantityType!, quantity: quantity, start: startDate, end: startDate, device: HKDevice.local(), metadata: newMetadata)
	}
}
