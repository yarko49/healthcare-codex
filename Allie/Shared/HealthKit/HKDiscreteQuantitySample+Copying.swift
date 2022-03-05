//
//  HKDiscreteQuantitySample+Copying.swift
//  Allie
//
//  Created by Waqar Malik on 10/12/21.
//

import CareModel
import Foundation
import HealthKit

extension HKDiscreteQuantitySample {
	convenience init(other: HKDiscreteQuantitySample, outcome: CHOutcome) {
		let metadata = other.metadata
		self.init(type: other.quantityType, quantity: other.quantity, start: other.startDate, end: other.endDate, device: other.device, metadata: metadata)
	}
}
