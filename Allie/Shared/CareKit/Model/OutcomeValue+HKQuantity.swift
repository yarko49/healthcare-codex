//
//  OutcomeValue+HKQuantity.swift
//  Allie
//
//  Created by Waqar Malik on 4/22/21.
//

import CareKitStore
import Foundation
import HealthKit

extension OutcomeValue {
	init?(quantity: HKQuantity, linkage: OCKHealthKitLinkage) {
		var unit = linkage.unit
		if linkage.quantityIdentifier == .bloodGlucose, unit.unitString != HKUnit.internationalUnit().unitString {
			unit = HKUnit.internationalUnit()
		}
		if !quantity.is(compatibleWith: unit) {
			return nil
		}
		let doubleValue = quantity.doubleValue(for: unit)
		switch linkage.quantityIdentifier {
		case .bloodGlucose, .heartRate, .restingHeartRate, .bloodPressureSystolic, .bloodPressureDiastolic, .stepCount:
			self.init(Int(doubleValue), units: unit.unitString)
		default:
			self.init(doubleValue, units: unit.unitString)
		}
	}
}
