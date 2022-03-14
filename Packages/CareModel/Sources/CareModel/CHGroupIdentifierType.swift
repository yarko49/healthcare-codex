//
//  CHGroupIdentifierType.swift
//  Ally
//
//  Created by Waqar Malik on 1/11/21.
//

import Foundation

public enum CHGroupIdentifierType: String, Hashable, CaseIterable {
	case simple = "SIMPLE"
	case labeledValue = "LABELED_VALUE"
	case numericProgress = "NUMERIC_PROGRESS"
	case grid = "GRID"
	case checklist = "CHECKLIST"
	case log = "LOG"
	case logInsulin = "LOG_INSULIN"
	case instruction = "INSTRUCTION"
	case featuredContent = "FEATURED_CONTENT"
	case link = "LINK"
	case symptoms = "SYMPTOMS"
	case dexcom = "INTEGRATION_DEXCOM"
	case cgm = "BLUETOOTH_CGM"
	case heartRate = "HEART_RATE"
	case restingHeartRate = "RESTING_HEART_RATE"
	case irregularHeartRhythm = "IRREGULAR_HEART_RHYTHM"
}
