//
//  GATTServiceCurrentTime.swift
//
//
//  Created by Waqar Malik on 2/5/22.
//

import CoreBluetooth
import Foundation

@frozen
public struct GATTServiceCurrentTime: GATTService {
	public static var rawIdentifier: Int { 0x1805 }

	public static var displayName: String {
		"Current Time"
	}

	public static var identifier: String {
		"currentTime"
	}

	public init() {}

	public static var services: [CBUUID] {
		[GATTServiceCurrentTime.uuid]
	}

	public static var characteristics: [CBUUID] {
		[GATTCurrentTime.uuid]
	}
}
