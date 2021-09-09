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

		self.init(name: device.name, manufacturer: nil, model: nil, udiDeviceIdentifier: nil, firmwareVersion: nil, hardwareVersion: nil, localIdentifier: device.identifier.uuidString, softwareVersion: nil)
	}
}

extension CHDevice {
	static var contourNextOne: CHDevice {
		self.init(name: "CONTOUR™", manufacturer: "Ascensia Diabetes Care", model: "NEXT ONE(US)", udiDeviceIdentifier: nil, firmwareVersion: nil, hardwareVersion: nil, localIdentifier: nil, softwareVersion: nil)
	}
}
