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
			return HKUnit.count().unitDivided(by: HKUnit.minute())
		case .count:
			return .count()
		case .countPerMin:
			return HKUnit.count().unitDivided(by: HKUnit.minute())
		case .lb:
			return .pound()
		case .literPerMin:
			return HKUnit.liter().unitDivided(by: HKUnit.minute())
		case .mmDL:
			return HKUnit.gramUnit(with: .milli).unitDivided(by: HKUnit.literUnit(with: .deci))
		case .mlPerKg:
			return HKUnit.literUnit(with: .milli).unitDivided(by: HKUnit.gramUnit(with: .kilo).unitMultiplied(by: HKUnit.minute()))
		case .mmHg:
			return .millimeterOfMercury()
		}
	}
}
