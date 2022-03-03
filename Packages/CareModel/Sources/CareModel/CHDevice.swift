//
//  CHDevice.swift
//  Allie
//
//  Created by Waqar Malik on 4/22/21.
//

import Foundation

public struct CHDevice: Codable, Equatable {
	public var name: String?
	public var manufacturer: String?
	public var model: String?
	public var udiDeviceIdentifier: String?
	public var firmwareVersion: String?
	public var hardwareVersion: String?
	public var localIdentifier: String?
	public var softwareVersion: String?

	public init(name: String?, manufacturer: String?, model: String?, udiDeviceIdentifier: String?, firmwareVersion: String?, hardwareVersion: String?, localIdentifier: String?, softwareVersion: String?) {
		self.name = name
		self.manufacturer = manufacturer
		self.model = model
		self.udiDeviceIdentifier = udiDeviceIdentifier
		self.firmwareVersion = firmwareVersion
		self.hardwareVersion = hardwareVersion
		self.localIdentifier = localIdentifier
		self.softwareVersion = softwareVersion
	}
}

public extension CHDevice {
	var uuid: UUID? {
		guard let identifier = localIdentifier else {
			return nil
		}
		return UUID(uuidString: identifier)
	}
}
