//
//  CHPerpherial+Contour.swift
//  Allie
//
//  Created by Waqar Malik on 1/23/22.
//

import AscensiaKit
import BluetoothService
import Foundation

extension CHPeripheral {
	init(device: Peripheral) {
		self.id = device.name ?? GATTDeviceService.bloodGlucose.hexString
		self.localId = device.identifier.uuidString
		self.name = device.name ?? GATTDeviceService.bloodGlucose.displayName
		self.type = GATTDeviceService.bloodGlucose.identifier
	}
}
