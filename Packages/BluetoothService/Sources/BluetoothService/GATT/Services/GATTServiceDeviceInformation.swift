//
//  GATTServiceDeviceInformation.swift
//
//
//  Created by Waqar Malik on 2/5/22.
//

import CoreBluetooth
import Foundation

@frozen
public struct GATTServiceDeviceInformation: GATTService {
	public static var rawIdentifier: Int { 0x180A }

	public static var displayName: String {
		"Device Information"
	}

	public static var identifier: String {
		"deviceInformation"
	}

	public init() {}
}
