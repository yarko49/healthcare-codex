//
//  UnitType.swift
//  Allie
//
//  Created by Waqar Malik on 1/15/21.
//

import Foundation
import HealthKit

enum UnitType: String, Codable, CaseIterable {
	case bpm
	case count
	case countPerMin = "count/min"
	case lb
	case literPerMin = "L/min"
	case mmDL = "mg/dl"
	case mlPerKg = "ml/(kg*min)"
	case mmHg
}

extension UnitType {
	var hkUnit: HKUnit {
		switch self {
		case .bpm:
			return HKUnit(from: "count/min")
		case .count:
			return .count()
		case .countPerMin:
			return HKUnit(from: "count/min")
		case .lb:
			return .pound()
		case .literPerMin:
			return HKUnit(from: rawValue)
		case .mmDL:
			return HKUnit(from: rawValue)
		case .mlPerKg:
			return HKUnit(from: rawValue)
		case .mmHg:
			return .millimeterOfMercury()
		}
	}
}
