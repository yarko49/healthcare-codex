//
//  GATTDeviceService.swift
//
//  Created by Waqar Malik on 12/9/21.
//

import Foundation

public enum GATTDeviceService: Int, BluetoothIdentifiable {
	case deviceInformation = 0x180A
	case bloodPressure = 0x1810
	case bloodGlucose = 0x1808
	case bodyComposition = 0x181B
	case heartRate = 0x180D
	case weightScale = 0x181D
}

public extension GATTDeviceService {
	var displayName: String {
		switch self {
		case .deviceInformation:
			return "Device Information"
		case .bloodPressure:
			return "Blood Pressure"
		case .bloodGlucose:
			return "Glucose"
		case .bodyComposition:
			return "Body Composition"
		case .heartRate:
			return "Heart Rate"
		case .weightScale:
			return "Weight Scale"
		}
	}

	var identifier: String {
		switch self {
		case .deviceInformation:
			return "deviceInformation"
		case .bloodPressure:
			return "bloodPressure"
		case .bloodGlucose:
			return "bloodGlucose"
		case .bodyComposition:
			return "bodyComposition"
		case .heartRate:
			return "heartRate"
		case .weightScale:
			return "weightScale"
		}
	}
}
