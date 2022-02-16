//
//  BluetoothDeviceType.swift
//  Allie
//
//  Created by Waqar Malik on 1/3/22.
//

import BluetoothService
import Foundation

extension GATTServiceBloodGlucose {
	static var title: String {
		NSLocalizedString("BLOOD_GLUCOSE_MONITOR", comment: "Blood Glucose Monitor")
	}
}

extension GATTServiceBloodPressure {
	static var title: String {
		NSLocalizedString("BLOOD_PRESSURE_MONITOR", comment: "Blood Pressure Monitor")
	}
}

extension GATTServiceWeightScale {
	static var title: String {
		NSLocalizedString("WEIGHT_SCALE", comment: "Weight Scale")
	}
}

extension GATTServiceBodyComposition {
	static var title: String {
		NSLocalizedString("BODY_COMPOSITION", comment: "Body Composition")
	}
}

extension GATTServiceHeartRate {
	static var title: String {
		NSLocalizedString("HEART_RATE", comment: "Heart Rate")
	}
}

extension GATTServiceDeviceInformation {
	static var title: String {
		NSLocalizedString("DEVICE_INFORMATION", comment: "Device Information")
	}
}

extension GATTServiceBatteryService {
	static var title: String {
		NSLocalizedString("BATTERY_SERVICE", comment: "Battery Service")
	}
}

extension GATTServiceCurrentTime {
	static var title: String {
		NSLocalizedString("CURRENT_TIME", comment: "Current Time")
	}
}
