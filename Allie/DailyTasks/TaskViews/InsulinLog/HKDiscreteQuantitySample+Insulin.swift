//
//  HKDiscreteQuantitySample.swift
//  Allie
//
//  Created by Waqar Malik on 5/19/21.
//

import Foundation
import HealthKit

extension HKDiscreteQuantitySample {
	convenience init(insulinUnits: Double, startDate: Date, reason: HKInsulinDeliveryReason) {
		let quantity = HKQuantity(unit: HKUnit(from: "IU"), doubleValue: insulinUnits)
		var metadata: [String: Any] = [:]
		metadata[HKMetadataKeyTimeZone] = TimeZone.current.identifier
		metadata[HKMetadataKeyWasUserEntered] = true
		metadata[HKMetadataKeyInsulinDeliveryReason] = NSNumber(value: reason.rawValue)
		let quantityType = HKQuantityType.quantityType(forIdentifier: .insulinDelivery)
		self.init(type: quantityType!, quantity: quantity, start: startDate, end: startDate, device: HKDevice.local(), metadata: metadata)
	}
}
