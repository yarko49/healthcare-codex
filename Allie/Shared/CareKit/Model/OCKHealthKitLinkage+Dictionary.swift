//
//  OCKHealthKitLinkage+Task.swift
//  Allie
//
//  Created by Waqar Malik on 5/8/21.
//

import CareKitStore
import Foundation
import HealthKit

extension OCKHealthKitLinkage {
	init?(linkage: [String: String]) {
		guard var identifier = linkage["quantityIdentifier"], let type = linkage["quantitytype"], var unitString = linkage["unit"] else {
			return nil
		}
		if identifier == "steps" {
			identifier = "stepCount"
		}

		if identifier == "bloodPressure" {
			identifier = "bloodPressureDiastolic"
		}

		guard let quantityType = OCKHealthKitLinkage.QuantityType(rawValue: type) else {
			return nil
		}

		if !identifier.hasPrefix("HKQuantityTypeIdentifier") {
			identifier = "HKQuantityTypeIdentifier" + identifier.capitalizingFirstLetter()
		}
		let quantityIdentifier = HKQuantityTypeIdentifier(rawValue: identifier)
		if quantityIdentifier == .insulinDelivery, unitString != HKUnit.internationalUnit().unitString {
			unitString = HKUnit.internationalUnit().unitString
		} else if quantityIdentifier == .bloodPressureDiastolic, unitString != HKUnit.millimeterOfMercury().unitString {
			unitString = "mmHg"
		}
		if unitString == "lbs" {
			unitString = "lb"
		}
		let unit = HKUnit(from: unitString)
		self.init(quantityIdentifier: quantityIdentifier, quantityType: quantityType, unit: unit)
	}
}
