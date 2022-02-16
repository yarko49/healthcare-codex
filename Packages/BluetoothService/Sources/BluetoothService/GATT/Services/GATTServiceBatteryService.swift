//
//  GATTServiceBatteryService.swift
//
//
//  Created by Waqar Malik on 2/5/22.
//

import CoreBluetooth
import Foundation

@frozen
public struct GATTServiceBatteryService: GATTService {
	public static var rawIdentifier: Int { 0x180F }

	public static var displayName: String {
		"Battery Service"
	}

	public static var identifier: String {
		"batteryService"
	}

	public init() {}

	public static var services: [CBUUID] {
		[GATTServiceBatteryService.uuid]
	}

	public static var characteristics: [CBUUID] {
		[GATTBatteryLevel.uuid]
	}
}
