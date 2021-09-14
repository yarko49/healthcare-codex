//
//  GATTCharacteristic.swift
//  Allie
//
//  Created by Waqar Malik on 8/25/21.
//

import CoreBluetooth
import Foundation

enum GATTCharacteristic: Int, CaseIterable {
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

extension GATTCharacteristic {
	static var deviceInfo: Set<GATTCharacteristic> {
		[.manufacturerDeviceName, .appearance, .manufacturerSystemId, .manufacturerModelNumber, .manufacturerSerialNumber, .firmwareRevision, .hardwareRevisions, .softwareRevision, .manufacturerName]
	}

	static var bloodGlucoseMeasurements: Set<GATTCharacteristic> {
		[.bloodGlucoseMeasurement, .bloodGlucoseMeasurementContext, .recordAccessControlPoint]
	}
}

extension GATTCharacteristic: BLEIdentifiable {}
