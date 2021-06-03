//
//  CodeableConcept+Supported.swift
//  Allie
//
//  Created by Waqar Malik on 3/11/21.
//

import ModelsR4

extension ModelsR4.CodeableConcept {
	class var heartRate: ModelsR4.CodeableConcept {
		ModelsR4.CodeableConcept(coding: [ModelsR4.Coding(code: "8867-4", display: "Heart rate", system: "http://loinc.org")])
	}

	class var restingHeartRate: ModelsR4.CodeableConcept {
		ModelsR4.CodeableConcept(coding: [ModelsR4.Coding(code: "40443-4", display: "Heart rate Resting", system: "http://loinc.org")])
	}

	class var bloodPressure: ModelsR4.CodeableConcept {
		ModelsR4.CodeableConcept(coding: [ModelsR4.Coding(code: "85354-9", display: "Blood pressure systolic and diastolic", system: "http://loinc.org")])
	}

	class var bloodPressureDiastolic: ModelsR4.CodeableConcept {
		ModelsR4.CodeableConcept(coding: [ModelsR4.Coding(code: "8462-4", display: "Diastolic blood pressure", system: "http://loinc.org")])
	}

	class var bloodPressureSystolic: ModelsR4.CodeableConcept {
		ModelsR4.CodeableConcept(coding: [ModelsR4.Coding(code: "8480-6", display: "Systolic blood pressure", system: "http://loinc.org"), ModelsR4.Coding(code: "271649006", display: "Systolic blood pressure", system: "http://snomed.info/sct")])
	}

	class var bodyMass: ModelsR4.CodeableConcept {
		ModelsR4.CodeableConcept(coding: [ModelsR4.Coding(code: "29463-7", display: "Body weight", system: "http://loinc.org"), ModelsR4.Coding(code: "3141-9", display: "Body weight measured", system: "http://loinc.org"), ModelsR4.Coding(code: "27113001", display: "Body weight", system: "http://snomed.info/sct")])
	}

	class var idealBodyMass: ModelsR4.CodeableConcept {
		ModelsR4.CodeableConcept(coding: [ModelsR4.Coding(code: "50064-5", display: "Ideal body weight", system: "http://loinc.org")])
	}

	class var height: ModelsR4.CodeableConcept {
		ModelsR4.CodeableConcept(coding: [ModelsR4.Coding(code: "8302-2", display: "Body height", system: "http://loinc.org")])
	}

	class var stepCount: ModelsR4.CodeableConcept {
		ModelsR4.CodeableConcept(coding: [ModelsR4.Coding(code: "55423-8", display: "Number of steps", system: "http://loinc.org")])
	}

	class var bloodGlucose: ModelsR4.CodeableConcept {
		ModelsR4.CodeableConcept(coding: [ModelsR4.Coding(code: "2339-0", display: "Glucose in Blood", system: "http://loinc.org")])
	}

	class var insulinDelivery: ModelsR4.CodeableConcept {
		ModelsR4.CodeableConcept(coding: [ModelsR4.Coding(code: "4287-9", display: "Insulin", system: "http://loinc.org")])
	}
}
