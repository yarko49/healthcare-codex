//
//  GATTServiceBloodPressure.swift
//
//
//  Created by Waqar Malik on 2/5/22.
//

import CoreBluetooth
import Foundation

@frozen
public struct GATTServiceBloodPressure: GATTService {
	public static var rawIdentifier: Int { 0x1810 }

	public static var displayName: String {
		"Blood Pressure"
	}

	public static var identifier: String {
		"bloodPressure"
	}

	public init() {}

	public static var services: [CBUUID] {
		[GATTServiceBloodPressure.uuid, GATTServiceBatteryService.uuid, GATTServiceCurrentTime.uuid]
	}

	public static var characteristics: [CBUUID] {
		[GATTBloodPressureMeasurement.uuid]
	}
}
