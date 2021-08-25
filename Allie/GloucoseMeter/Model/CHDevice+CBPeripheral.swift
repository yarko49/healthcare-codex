//
//  CHDevice+CBPeripheral.swift
//  Allie
//
//  Created by Waqar Malik on 8/16/21.
//

import CoreBluetooth
import Foundation

extension CHDevice {
	init?(peripheral: CBPeripheral?) {
		guard let device = peripheral else {
			return nil
		}

		self.init(name: device.name, model: nil, udiDeviceIdentifier: nil, firmwareVersion: nil, hardwareVersion: nil, localIdentifier: device.identifier.uuidString, manufacturer: nil, softwareVersion: nil)
	}
}
