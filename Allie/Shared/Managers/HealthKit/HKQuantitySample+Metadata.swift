//
//  HKQuantitySample+Metadata.swift
//  Allie
//
//  Created by Waqar Malik on 2/20/21.
//

import Foundation
import HealthKit

extension HKQuantitySample {
	var ch_isUserEntered: Bool {
		metadata?[HKMetadataKeyWasUserEntered] as? Bool ?? false
	}
}
