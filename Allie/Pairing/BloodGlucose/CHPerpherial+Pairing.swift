//
//  CHPerpherial+Contour.swift
//  Allie
//
//  Created by Waqar Malik on 1/23/22.
//

import BluetoothService
import Foundation
import OmronKit

extension CHPeripheral {
	init(peripheral: Peripheral, type: String) throws {
		let discoveryInfo = OHQDeviceDiscoveryInfo(peripheral: peripheral.peripheral, rawAdvertisementData: peripheral.advertisementData.advertisementData, rssi: peripheral.rssi)
		let deviceInfo: [OHQDeviceInfoKey: Any] = discoveryInfo.deviceInfo
		let advertisementData = deviceInfo.advertisementData
		let manufacturerData: [OHQManufacturerDataKey: Any]? = advertisementData?.manufacturerData

		guard let name = discoveryInfo.modelName ?? peripheral.name else {
			throw AllieError.missing("name")
		}
		self.id = advertisementData?.localName ?? name
		self.localId = peripheral.identifier.uuidString
		self.name = name
		self.type = type
	}
}
