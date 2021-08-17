//
//  HKDevice+CBPrepherial.swift
//  Allie
//
//  Created by Waqar Malik on 8/16/21.
//

import CoreBluetooth
import Foundation
import HealthKit

extension HKDevice {
	convenience init?(peripheral: CBPeripheral?) {
		guard let device = peripheral else {
			return nil
		}

		self.init(name: device.name, manufacturer: nil, model: nil, hardwareVersion: nil, firmwareVersion: nil, softwareVersion: nil, localIdentifier: device.identifier.uuidString, udiDeviceIdentifier: nil)
	}
}
