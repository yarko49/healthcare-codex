//
//  GATTServiceHeartRate.swift
//
//
//  Created by Waqar Malik on 2/5/22.
//

import CoreBluetooth
import Foundation

@frozen
public struct GATTServiceHeartRate: GATTService {
	public static var rawIdentifier: Int { 0x180D }

	public static var displayName: String {
		"Heart Rate"
	}

	public static var identifier: String {
		"heartRate"
	}

	public init() {}
}
