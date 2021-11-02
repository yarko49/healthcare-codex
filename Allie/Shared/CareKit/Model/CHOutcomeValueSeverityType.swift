//
//  CHOutcomeValueSeverityType.swift
//  Allie
//
//  Created by Waqar Malik on 10/27/21.
//

import Foundation

enum CHOutcomeValueSeverityType: String, Codable, Hashable, CaseIterable {
	case mild
	case moderate
	case severe

	init?(title: String) {
		switch title {
		case NSLocalizedString("SYMPTOM_MILD", comment: "Mild"):
			self = .mild
		case NSLocalizedString("SYMPTOM_MODERATE", comment: "Moderate"):
			self = .moderate
		case NSLocalizedString("SYMPTOM_SEVERE", comment: "Severe"):
			self = .severe
		default:
			return nil
		}
	}
}

extension CHOutcomeValueSeverityType {
	var title: String {
		switch self {
		case .mild:
			return NSLocalizedString("SYMPTOM_MILD", comment: "Mild")
		case .moderate:
			return NSLocalizedString("SYMPTOM_MODERATE", comment: "Moderate")
		case .severe:
			return NSLocalizedString("SYMPTOM_SEVERE", comment: "Severe")
		}
	}
}
