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
			return [EntryTimePickerView.reuseIdentifier]
		case .insulinDelivery, .bloodGlucose:
			return [EntryTimePickerView.reuseIdentifier, EntrySegmentedView.reuseIdentifier]
		case .bloodPressureSystolic, .bloodPressureDiastolic:
			return [EntryMultiValueEntryView.reuseIdentifier, EntryTimePickerNoValueView.reuseIdentifier]
		default:
			return nil
		}
	}
}
