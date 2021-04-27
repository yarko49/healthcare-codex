//
//  HealthKitLinkage.swift
//  Allie
//
//  Created by Waqar Malik on 1/15/21.
//

import CareKitStore
import Foundation
import HealthKit

public struct HealthKitLinkage: Codable {
	let identifier: QuantityIdentifier
	let type: OCKHealthKitLinkage.QuantityType
	let unit: UnitType

	private enum CodingKeys: String, CodingKey {
		case identifier = "quantityIdentifier"
		case type = "quantitytype"
		case unit
	}
}

extension HealthKitLinkage {
	init?(identifier: String, type: String, unit: String) {
		guard let quantityIdentifier = QuantityIdentifier(rawValue: identifier), let quantityType = OCKHealthKitLinkage.QuantityType(rawValue: type), let unitType = UnitType(rawValue: unit) else {
			return nil
		}

		self.init(identifier: quantityIdentifier, type: quantityType, unit: unitType)
	}
}

extension HealthKitLinkage {
	var hkLinkage: OCKHealthKitLinkage {
		OCKHealthKitLinkage(quantityIdentifier: identifier.hkQuantityIdentifier, quantityType: type, unit: unit.hkUnit)
	}

	var hkQuantityType: HKQuantityType? {
		HKQuantityType.quantityType(forIdentifier: identifier.hkQuantityIdentifier)
	}
}

extension OCKHealthKitLinkage {
	var hkQuantityType: HKQuantityType? {
		HKQuantityType.quantityType(forIdentifier: quantityIdentifier)
	}
}
