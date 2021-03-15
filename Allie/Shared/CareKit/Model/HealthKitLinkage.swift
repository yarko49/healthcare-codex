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
	var hkLinkage: OCKHealthKitLinkage {
		OCKHealthKitLinkage(quantityIdentifier: identifier.hkQuantityIdentifier, quantityType: type, unit: unit.hkUnit)
	}
}
