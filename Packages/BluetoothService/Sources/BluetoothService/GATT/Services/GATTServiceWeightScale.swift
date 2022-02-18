//
//  GATTServiceWeightScale.swift
//
//
//  Created by Waqar Malik on 2/5/22.
//

import CoreBluetooth
import Foundation

@frozen
public struct GATTServiceWeightScale: GATTService {
	public static var rawIdentifier: Int { 0x181D }

	public static var displayName: String {
		"Weight Scale"
	}

	public static var identifier: String {
		"weightScale"
	}

	public init() {}

	public static var services: [CBUUID] {
		[GATTServiceWeightScale.uuid, GATTServiceBatteryService.uuid, GATTServiceCurrentTime.uuid]
	}

	public static var characteristics: [CBUUID] {
		[GATTWeightMeasurement.uuid]
	}
}
