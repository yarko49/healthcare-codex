//
//  HKDiscreteQuantitySample.swift
//  Allie
//
//  Created by Waqar Malik on 5/19/21.
//

import Foundation
import HealthKit

public extension HKDiscreteQuantitySample {
	convenience init(insulinUnits: Double, startDate: Date, reason: HKInsulinDeliveryReason) {
		let quantity = HKQuantity(unit: HKUnit.internationalUnit(), doubleValue: insulinUnits)
		var metadata: [String: Any] = [:]
		metadata[HKMetadataKeyTimeZone] = TimeZone.current.identifier
		metadata[HKMetadataKeyWasUserEntered] = true
		metadata[HKMetadataKeyInsulinDeliveryReason] = NSNumber(value: reason.rawValue)
		metadata[CHMetadataKeyUpdatedDate] = Date()
		let quantityType = HKQuantityType.quantityType(forIdentifier: .insulinDelivery)
		self.init(type: quantityType!, quantity: quantity, start: startDate, end: startDate, device: HKDevice.local(), metadata: metadata)
	}
}
