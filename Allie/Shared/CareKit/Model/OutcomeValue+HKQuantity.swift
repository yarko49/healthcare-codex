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
		if !quantity.is(compatibleWith: linkage.unit) {
			return nil
		}
		let doubleValue = quantity.doubleValue(for: linkage.unit)
		self.init(doubleValue, units: linkage.unit.unitString)
	}
}
