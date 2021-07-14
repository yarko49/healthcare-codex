//
//  HKQuantityTypeIdentifier+TaskViews.swift
//  Allie
//
//  Created by Waqar Malik on 7/13/21.
//

import Foundation
import HealthKit

extension HKQuantityTypeIdentifier {
	var taskViews: [String]? {
		switch self {
		case .bodyMass:
			return [TimeValueEntryView.reuseIdentifier]
		case .insulinDelivery, .bloodGlucose:
			return [TimeValueEntryView.reuseIdentifier, SegmentedEntryView.reuseIdentifier]
		case .bloodPressureSystolic, .bloodPressureDiastolic:
			return [MultiValueEntryView.reuseIdentifier]
		default:
			return nil
		}
	}
}
