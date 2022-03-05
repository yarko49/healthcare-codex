//
//  OCKOutcomeValue+Conversion.swift
//  Allie
//
//  Created by Waqar Malik on 12/8/20.
//

import CareKitStore
import Foundation

public extension OCKOutcomeValue {
	init(outcomeValue: CHOutcomeValue) {
		self.init(outcomeValue.value, units: outcomeValue.units)
		self.createdDate = outcomeValue.createdDate
		self.kind = outcomeValue.kind
	}

	mutating func updateValue(newValue: OCKOutcomeValueUnderlyingType, newQuantityIdentifier: String?, newKind: String?) {
		value = newValue
		quantityIdentifier = newQuantityIdentifier ?? quantityIdentifier
		kind = newKind ?? kind
	}
}

public extension CHOutcomeValue {
	init(ockOutcomeValue: OCKOutcomeValue) {
		self.init(ockOutcomeValue.value, units: ockOutcomeValue.units)
		self.kind = ockOutcomeValue.kind
	}
}
