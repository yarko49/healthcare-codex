//
//  GATTServiceBloodGlucose.swift
//
//
//  Created by Waqar Malik on 2/5/22.
//

import CoreBluetooth
import Foundation

@frozen
public struct GATTServiceBloodGlucose: GATTService {
	public static var rawIdentifier: Int { 0x1808 }

	public static var displayName: String {
		"Blood Glucose"
	}

	public static var identifier: String {
		"bloodGlucose"
	}

	public init() {}

	public static var services: [CBUUID] {
		[GATTServiceBloodGlucose.uuid]
	}

	public static var characteristics: [CBUUID] {
		[GATTBloodGlucoseMeasurement.uuid, GATTBloodGlucoseMeasurementContext.uuid, GATTRecordAccessControlPoint.uuid]
	}
}
