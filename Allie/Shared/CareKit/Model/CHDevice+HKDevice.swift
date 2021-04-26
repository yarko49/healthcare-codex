//
//  CHDevice+HKDevice.swift
//  Allie
//
//  Created by Waqar Malik on 4/22/21.
//

import Foundation
import HealthKit

extension CHDevice {
	init(device: HKDevice) {
		name = device.name
		model = device.model
		udiDeviceIdentifier = device.udiDeviceIdentifier
		firmwareVersion = device.firmwareVersion
		hardwareVersion = device.hardwareVersion
		localIdentifier = device.localIdentifier
		manufacturer = device.manufacturer
		softwareVersion = device.softwareVersion
	}
}
