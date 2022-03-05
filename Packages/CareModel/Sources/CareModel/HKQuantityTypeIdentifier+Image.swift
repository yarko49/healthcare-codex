//
//  HKQuantityTypeIdentifier+Image.swift
//  Allie
//
//  Created by Waqar Malik on 5/24/21.
//

import HealthKit
import UIKit

public extension HKQuantityTypeIdentifier {
	var assetName: String? {
		switch self {
		case .bloodGlucose:
			return "icon-blood-glucose"
		case .heartRate:
			return "icon-heart-rate"
		case .bodyMass:
			return "icon-weight"
		default:
			return nil
		}
	}

	var cardIcon: UIImage? {
		switch self {
		case .bloodGlucose:
			return UIImage(named: "icon-blood-glucose")
		case .heartRate:
			return UIImage(named: "icon-heart-rate")
		case .bodyMass:
			return UIImage(named: "icon-weight")
		default:
			return nil
		}
	}
}
