//
//  BGMSampleType.swift
//  Allie
//
//  Created by Waqar Malik on 7/27/21.
//

import Foundation

enum BGMSampleType: String {
	case capillaryWholeBlood
	case controlSolution
	case other

	init(measurement: Int) {
		if measurement == 1 {
			self = .capillaryWholeBlood
		} else if measurement == 10 {
			self = .controlSolution
		} else {
			self = .other
		}
	}
}

extension BGMSampleType: CustomStringConvertible {
	var description: String {
		switch self {
		case .capillaryWholeBlood:
			return "Capillary Whole blood"
		case .controlSolution:
			return "Control Solution"
		case .other:
			return"Other"
		}
	}
}
