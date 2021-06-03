//
//  HKInsulinDeliveryReason+Display.swift
//  Allie
//
//  Created by Waqar Malik on 5/20/21.
//

import HealthKit

extension HKInsulinDeliveryReason {
	init?(kind: String) {
		if kind == "bolus" {
			self = .bolus
		} else if kind == "basal" {
			self = .basal
		} else {
			return nil
		}
	}

	var title: String {
		switch self {
		case .bolus:
			return NSLocalizedString("FAST_ACTING", comment: "Fast Acting")
		case .basal:
			return NSLocalizedString("LONG_ACTING", comment: "Long Acting")
		@unknown default:
			return ""
		}
	}

	var kind: String {
		switch self {
		case .bolus:
			return "bolus"
		case .basal:
			return "basal"
		@unknown default:
			return ""
		}
	}
}
