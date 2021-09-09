//
//  CHDevice.swift
//  Allie
//
//  Created by Waqar Malik on 4/22/21.
//

import Foundation

public struct CHDevice: Codable {
	public var name: String?
	public var manufacturer: String?
	public var model: String?
	public var udiDeviceIdentifier: String?
	public var firmwareVersion: String?
	public var hardwareVersion: String?
	public var localIdentifier: String?
	public var softwareVersion: String?
}

public extension CHDevice {
	var uuid: UUID? {
		guard let identifier = localIdentifier else {
			return nil
		}
		return UUID(uuidString: identifier)
	}
}
