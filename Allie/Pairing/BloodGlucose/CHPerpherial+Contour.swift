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
	init(device: Peripheral, type: String) throws {
		guard let name = device.name else {
			throw AllieError.missing("name")
		}
		self.id = name
		self.localId = device.identifier.uuidString
		self.name = name
		self.type = type
	}
}
