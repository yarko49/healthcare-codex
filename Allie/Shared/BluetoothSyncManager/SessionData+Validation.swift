//
//  BSOSessionData+Validation.swift
//  Allie
//
//  Created by Waqar Malik on 2/11/22.
//

import Foundation
import OmronKit

extension SessionData {
	var isSessionDataValid: Bool {
		if completionReason == .disconnected {
			return false
		}
		if currentTime == nil, batteryLevel == nil, let isEmpty = measurementRecords?.isEmpty, isEmpty == true {
			return false
		}
		guard let readMeasurementRecords = options?.readMeasurementRecords, readMeasurementRecords, measurementRecords != nil else {
			return false
		}
		return true
	}
}
