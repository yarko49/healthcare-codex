//
//  HKQuantityTypeIdentifier+Linkage.swift
//  Allie
//
//  Created by Waqar Malik on 7/11/21.
//

import Foundation
import HealthKit

extension HKQuantityTypeIdentifier {
	var dataType: HealthKitDataType? {
		switch self {
		case .bodyMass:
			return .bodyMass
		case .heartRate:
			return .heartRate
		case .restingHeartRate:
			return .restingHeartRate
		case .stepCount:
			return .stepCount
		case .bloodGlucose:
			return .bloodGlucose
		case .insulinDelivery:
			return .insulinDelivery
		default:
			return nil
		}
	}
}
