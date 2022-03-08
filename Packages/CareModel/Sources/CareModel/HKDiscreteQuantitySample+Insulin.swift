//
//  HKDiscreteQuantitySample.swift
//  Allie
//
//  Created by Waqar Malik on 5/19/21.
//

import Foundation
import HealthKit

public extension HKDiscreteQuantitySample {
	convenience init(insulinUnits: Double, startDate: Date, reason: HKInsulinDeliveryReason, metadata: [String: Any]?) {
		let quantity = HKQuantity(unit: HKUnit.internationalUnit(), doubleValue: insulinUnits)
		var newMetadata: [String: Any] = metadata ?? [:]
		newMetadata[HKMetadataKeyTimeZone] = TimeZone.current.identifier
		newMetadata[HKMetadataKeyWasUserEntered] = true
		newMetadata[HKMetadataKeyInsulinDeliveryReason] = NSNumber(value: reason.rawValue)
		newMetadata[CHMetadataKeyUpdatedDate] = Date()
		let quantityType = HKQuantityType.quantityType(forIdentifier: .insulinDelivery)
		self.init(type: quantityType!, quantity: quantity, start: startDate, end: startDate, device: HKDevice.local(), metadata: newMetadata)
	}
}
