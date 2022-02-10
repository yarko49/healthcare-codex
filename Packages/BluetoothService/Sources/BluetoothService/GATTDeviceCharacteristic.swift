//
//  File.swift
//
//
//  Created by Waqar Malik on 12/9/21.
//

import CoreBluetooth
import Foundation

public enum GATTDeviceCharacteristic: Int, BluetoothIdentifiable {
	case manufacturerDeviceName = 0x2A00
	case appearance = 0x2A01
	case manufacturerSystemId = 0x2A23
	case manufacturerModelNumber = 0x2A24
	case manufacturerSerialNumber = 0x2A25
	case firmwareRevision = 0x2A26
	case hardwareRevisions = 0x2A27
	case softwareRevision = 0x2A28
	case manufacturerName = 0x2A29

	case bloodPressureFeature = 0x2A49
	case bloodPressureMeasurement = 0x2A35
	case bodySensorLocation = 0x2A38
	case bloodGlucoseFeature = 0x2A51
	case bloodGlucoseMeasurement = 0x2A18
	case bloodGlucoseMeasurementContext = 0x2A34
	case heartRateControlPoint = 0x2A39
	case heartRateMeasurement = 0x2A37
	case recordAccessControlPoint = 0x2A52
	case timeZone = 0x2A0E
	case currentTime = 0x2A2B
}

public extension GATTDeviceCharacteristic {
	var displayName: String {
		switch self {
		case .manufacturerDeviceName:
			return "Device Name"
		case .appearance:
			return "Appearance"
		case .manufacturerSystemId:
			return "System Id"
		case .manufacturerModelNumber:
			return "Model Number"
		case .manufacturerSerialNumber:
			return "Serial Number"
		case .firmwareRevision:
			return "Firmware Revision"
		case .hardwareRevisions:
			return "Hardware Revision"
		case .softwareRevision:
			return "Software Revision"
		case .manufacturerName:
			return "Manufacturer Name"
		case .bloodPressureFeature:
			return "Blood Pressure"
		case .bloodPressureMeasurement:
			return "Blood Presure Measurement"
		case .bodySensorLocation:
			return "Sensor Location"
		case .bloodGlucoseFeature:
			return "Blood Glucose"
		case .bloodGlucoseMeasurement:
			return "Blood Glucose Measurement"
		case .bloodGlucoseMeasurementContext:
			return "Blood Glucose Measurement Context"
		case .heartRateControlPoint:
			return "Heart Rate Control Point"
		case .heartRateMeasurement:
			return "Heart Rate Measurement"
		case .recordAccessControlPoint:
			return "Record Access Control Point"
		case .timeZone:
			return "Timezone"
		case .currentTime:
			return "Current Time"
		}
	}
}

public extension GATTDeviceCharacteristic {
	static var deviceInfo: Set<GATTDeviceCharacteristic> {
		[.manufacturerDeviceName, .appearance, .manufacturerSystemId, .manufacturerModelNumber, .manufacturerSerialNumber, .firmwareRevision, .hardwareRevisions, .softwareRevision, .manufacturerName]
	}

	static var bloodGlucoseMeasurements: Set<GATTDeviceCharacteristic> {
		[.bloodGlucoseMeasurement, .bloodGlucoseMeasurementContext, .recordAccessControlPoint]
	}

	static var bloodPressureMeasurements: Set<GATTDeviceCharacteristic> {
		[.bloodPressureFeature, .bloodPressureMeasurement, .manufacturerDeviceName, .heartRateMeasurement, .heartRateControlPoint]
	}
}
