//
//  OCKOutcomeValue+Conversion.swift
//  Allie
//
//  Created by Waqar Malik on 12/8/20.
//

import CareKitStore
import Foundation

extension OCKOutcomeValue {
	init(outcomeValue: OutcomeValue) {
		self.init(outcomeValue.value, units: outcomeValue.units)
		self.createdDate = outcomeValue.createdDate
		self.kind = outcomeValue.kind
	}
}

extension OutcomeValue {
	init(ockOutcomeValue: OCKOutcomeValue) {
		self.init(ockOutcomeValue.value, units: ockOutcomeValue.units)
		self.kind = ockOutcomeValue.kind
	}
}
