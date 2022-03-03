//
//  HKCorrelationTypeIdentifier+Linkage.swift
//  Allie
//
//  Created by Waqar Malik on 7/11/21.
//

import CareModel
import Foundation
import HealthKit

extension HKCorrelationTypeIdentifier {
	var dataType: HealthKitDataType? {
		switch self {
		case .bloodPressure:
			return .bloodPressure
		default:
			return nil
		}
	}
}
