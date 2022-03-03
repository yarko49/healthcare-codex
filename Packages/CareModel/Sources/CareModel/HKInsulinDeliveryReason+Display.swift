//
//  HKInsulinDeliveryReason+Display.swift
//  Allie
//
//  Created by Waqar Malik on 5/20/21.
//

import Foundation
import HealthKit

public extension HKInsulinDeliveryReason {
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

	var rawKind: String {
		switch self {
		case .bolus:
			return "bolus"
		case .basal:
			return "basal"
		@unknown default:
			return ""
		}
	}

	var valueRange: ClosedRange<Double> {
		switch self {
		case .basal:
			return 0.0 ... 300
		case .bolus:
			return 0.0 ... 150
		@unknown default:
			return 0.0 ... 300
		}
	}
}
