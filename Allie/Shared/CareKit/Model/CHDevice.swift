//
//  CHDevice.swift
//  Allie
//
//  Created by Waqar Malik on 4/22/21.
//

import Foundation

struct CHDevice: Codable {
	var name: String?
	var manufacturer: String?
	var model: String?
	var udiDeviceIdentifier: String?
	var firmwareVersion: String?
	var hardwareVersion: String?
	var localIdentifier: String?
	var softwareVersion: String?
}

extension CHDevice {
	var uuid: UUID? {
		guard let identifier = localIdentifier else {
			return nil
		}
		return UUID(uuidString: identifier)
	}
}
