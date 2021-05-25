//
//  HKCorrelationTypeIdentifier+Image.swift
//  Allie
//
//  Created by Waqar Malik on 5/24/21.
//

import HealthKit
import UIKit

extension HKCorrelationTypeIdentifier {
	var assetName: String? {
		switch self {
		case .bloodPressure:
			return "icon-blood-pressure"
		default:
			return nil
		}
	}

	var cardIcon: UIImage? {
		switch self {
		case .bloodPressure:
			return UIImage(named: "icon-blood-pressure")
		default:
			return nil
		}
	}
}
