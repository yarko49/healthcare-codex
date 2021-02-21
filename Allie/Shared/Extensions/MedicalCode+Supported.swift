//
//  MedicalCoding+Supported.swift
//  Allie
//
//  Created by Waqar Malik on 1/28/21.
//

import Foundation

extension MedicalCode {
	static let heartRate = MedicalCode(coding: [MedicalCode.Coding(system: "http://loinc.org", code: "8867-4", display: "Heart rate")])
	static let restingHeartRate = MedicalCode(coding: [MedicalCode.Coding(system: "http://loinc.org", code: "40443-4", display: "Heart rate Resting")])
	static let bloodPressure = MedicalCode(coding: [MedicalCode.Coding(system: "http://loinc.org", code: "85354-9", display: "Blood pressure systolic and diastolic")])
	static let bodyWeight = MedicalCode(coding: [MedicalCode.Coding(system: "http://loinc.org", code: "29463-7", display: "Body weight"), MedicalCode.Coding(system: "http://loinc.org", code: "3141-9", display: "Body weight measured"), MedicalCode.Coding(system: "http://snomed.info/sct", code: "27113001", display: "Body weight")])
	static let idealBodyWeight = MedicalCode(coding: [MedicalCode.Coding(system: "http://loinc.org", code: "50064-5", display: "Ideal body weight")])
	static let bodyHeight = MedicalCode(coding: [MedicalCode.Coding(system: "http://loinc.org", code: "8302-2", display: "Body height")])
	static let diastolicBloodPressure = MedicalCode(coding: [MedicalCode.Coding(system: "http://loinc.org", code: "8462-4", display: "Diastolic blood pressure")])
	static let systolicBloodPressure = MedicalCode(coding: [MedicalCode.Coding(system: "http://loinc.org", code: "8480-6", display: "Systolic blood pressure"), MedicalCode.Coding(system: "http://snomed.info/sct", code: "271649006", display: "Systolic blood pressure")])
	static let stepsCount = MedicalCode(coding: [MedicalCode.Coding(system: "http://loinc.org", code: "55423-8", display: "Number of steps")])
	static let bloodGlucose = MedicalCode(coding: [MedicalCode.Coding(system: "http://loinc.org", code: "2339-0", display: "Glucose in Blood")])
}
