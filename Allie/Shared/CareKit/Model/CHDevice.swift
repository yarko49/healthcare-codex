//
//  CHDevice.swift
//  Allie
//
//  Created by Waqar Malik on 4/22/21.
//

import Foundation

public struct CHDevice: Codable {
	public let name: String?
	public let model: String?
	public let udiDeviceIdentifier: String?
	public let firmwareVersion: String?
	public let hardwareVersion: String?
	public let localIdentifier: String?
	public let manufacturer: String?
	public let softwareVersion: String?
}

public extension CHDevice {
	var uuid: UUID? {
		guard let identifier = localIdentifier else {
			return nil
		}
		return UUID(uuidString: identifier)
	}
}
