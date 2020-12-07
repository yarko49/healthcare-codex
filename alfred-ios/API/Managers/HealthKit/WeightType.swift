//  HealthQualityType.swift

import Foundation
import HealthKit
import UIKit

enum WeightType: String, CaseIterable {
	case healthy = "Healthy"
	case heavy = "Heavy"
	case obese = "Obese"

	func getHKitQualityString() -> String? {
		switch self {
		case .healthy:
			return Str.healthy
		case .heavy:
			return Str.heavy
		case .obese:
			return Str.obese
		}
	}

	func getImage() -> UIImage {
		switch self {
		case .healthy:
			return UIImage(named: "healthy") ?? UIImage()
		case .heavy:
			return UIImage(named: "heavy") ?? UIImage()
		case .obese:
			return UIImage(named: "obese") ?? UIImage()
		}
	}
}
