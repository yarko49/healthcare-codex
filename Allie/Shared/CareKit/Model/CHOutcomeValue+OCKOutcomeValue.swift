//
//  OCKOutcomeValue+Conversion.swift
//  Allie
//
//  Created by Waqar Malik on 12/8/20.
//

import CareKitStore
import Foundation

extension OCKOutcomeValue {
	init(outcomeValue: CHOutcomeValue) {
		self.init(outcomeValue.value, units: outcomeValue.units)
		self.createdDate = outcomeValue.createdDate
		self.kind = outcomeValue.kind
	}
    
    mutating func updateValue(newValue: OCKOutcomeValueUnderlyingType,
                              newQuantityIdentifier: String?,
                              newKind: String?) {
        self.value = newValue
        self.quantityIdentifier = newQuantityIdentifier ?? self.quantityIdentifier
        self.kind = newKind ?? self.kind
    }
}

extension CHOutcomeValue {
	init(ockOutcomeValue: OCKOutcomeValue) {
		self.init(ockOutcomeValue.value, units: ockOutcomeValue.units)
		self.kind = ockOutcomeValue.kind
	}
}
