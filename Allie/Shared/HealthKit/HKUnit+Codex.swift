//
//  HKUnit+Codex.swift
//  Allie
//
//  Created by Waqar Malik on 8/4/21.
//

import Foundation
import HealthKit

extension HKUnit {
	var displayUnitSting: String {
		guard self == HKUnit.internationalUnit() else {
			return unitString
		}

		return NSLocalizedString("INSULIN_UNIT", comment: "Unit")
	}
}
