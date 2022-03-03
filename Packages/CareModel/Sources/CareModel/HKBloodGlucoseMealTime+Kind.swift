//
//  HKBloodGlucoseMealTime+Kind.swift
//  Allie
//
//  Created by Waqar Malik on 9/2/21.
//

import Foundation
import HealthKit

public extension HKBloodGlucoseMealTime {
	var kind: String? {
		switch self {
		case .postprandial:
			return CHBloodGlucoseMealTime.postprandial.kind
		case .preprandial:
			return CHBloodGlucoseMealTime.preprandial.kind
		default:
			return nil
		}
	}
}
