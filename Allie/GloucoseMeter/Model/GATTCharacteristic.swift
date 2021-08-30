//
//  GATTCharacteristic.swift
//  Allie
//
//  Created by Waqar Malik on 8/25/21.
//

import Foundation

enum GATTCharacteristic: Int {
	case bloodPressureFeature = 0x2A49
	case bloodPressureMeasurement = 0x2A35
	case bodySensorLocation = 0x2A38
	case firmwareRevisionString = 0x2A26
	case bloodGlucoseFeature = 0x2A51
	case bloodGlucoseMeasurement = 0x2A18
	case bloodGlucoseMeasurementContext = 0x2A34
	case hardwareRevisionsString = 0x2A27
	case heartRateControlPoint = 0x2A39
	case heartRateMeasurement = 0x2A37
	case manufacturerNameString = 0x2A29
	case manufacturerModelNumberString = 0x2A24
	case recordAccessControlPoint = 0x2A52
	case serialNumberString = 0x2A25
	case softwareRevisionString = 0x2A28
	case systemId = 0x2A23
	case timeZone = 0x2A0E
}

extension GATTCharacteristic: BLEIdentifiable {}
