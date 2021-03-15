//
//  ObservationComponent+HKQuantitySample.swift
//  Allie
//
//  Created by Waqar Malik on 3/11/21.
//

import HealthKit
import ModelsR4

extension ModelsR4.ObservationComponent {
	convenience init(code: CodeableConcept, sample: HKQuantitySample, unit: HKUnit) {
		let fhirUnit = FHIRPrimitive<FHIRString>(stringLiteral: unit.unitString)
		let fhirValue = FHIRPrimitive<FHIRDecimal>(floatLiteral: sample.quantity.doubleValue(for: unit))
		self.init(code: code, value: .quantity(Quantity(unit: fhirUnit, value: fhirValue)))
	}
}
