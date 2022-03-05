//
//  CHGroupIdentifierType+Views.swift
//  Allie
//
//  Created by Waqar Malik on 10/26/21.
//

import CareModel
import Foundation
import HealthKit

extension CHGroupIdentifierType {
	var taskViews: [String]? {
		switch self {
		case .logInsulin:
			return [EntryTimePickerView.reuseIdentifier, EntrySegmentedView.reuseIdentifier]
		case .symptoms:
			return [EntryListPickerView.reuseIdentifier, EntrySegmentedView.reuseIdentifier]
		default:
			return nil
		}
	}

	var segmentTitles: [String] {
		switch self {
		case .logInsulin:
			return [HKInsulinDeliveryReason.bolus.title, HKInsulinDeliveryReason.basal.title]
		case .symptoms:
			return [CHOutcomeValueSeverityType.mild, .moderate, .severe].map { severityType in
				severityType.title
			}
		default:
			return []
		}
	}
}
