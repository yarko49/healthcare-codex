//
//  BluetoothDeviceType.swift
//  Allie
//
//  Created by Waqar Malik on 1/3/22.
//

import BluetoothService
import Foundation
import OmronKit

extension GATTDeviceService {
	init?(service: String) {
		switch service {
		case GATTDeviceService.bloodGlucose.hexString:
			self = .bloodGlucose
		case GATTDeviceService.bloodPressure.hexString:
			self = .bloodPressure
		case GATTDeviceService.weightScale.hexString:
			self = .weightScale
		case GATTDeviceService.bodyComposition.hexString:
			self = .bodyComposition
		case GATTDeviceService.heartRate.hexString:
			self = .heartRate
		case GATTDeviceService.deviceInformation.hexString:
			self = .deviceInformation
		default:
			return nil
		}
	}

	var title: String {
		switch self {
		case .bloodGlucose:
			return NSLocalizedString("BLOOD_GLUCOSE_MONITOR", comment: "Blood Glucose Monitor")
		case .bloodPressure:
			return NSLocalizedString("BLOOD_PRESSURE_MONITOR", comment: "Blood Pressure Monitor")
		case .weightScale:
			return NSLocalizedString("WEIGHT_SCALE", comment: "Weight Scale")
		case .bodyComposition:
			return NSLocalizedString("BODY_COMPOSITION", comment: "Body Composition")
		case .heartRate:
			return NSLocalizedString("HEART_RATE", comment: "Heart Rate")
		case .deviceInformation:
			return NSLocalizedString("DEVICE_INFORMATION", comment: "Device Information")
		}
	}
}
