//
//  CHPerpherial+Contour.swift
//  Allie
//
//  Created by Waqar Malik on 1/23/22.
//

import BluetoothService
import CareModel
import CoreBluetooth
import Foundation
import OmronKit

extension CHPeripheral {
	init(peripheral: Peripheral, type: String) throws {
		let discoveryInfo = OHQDeviceDiscoveryInfo(peripheral: peripheral.peripheral, rawAdvertisementData: peripheral.advertisementData.advertisementData, rssi: peripheral.rssi)
		let deviceInfo: [OHQDeviceInfoKey: Any] = discoveryInfo.deviceInfo
		let advertisementData = deviceInfo.advertisementData
		// let manufacturerData: [OHQManufacturerDataKey: Any]? = advertisementData?.manufacturerData

		guard let name = discoveryInfo.modelName ?? peripheral.name else {
			throw AllieError.missing("name")
		}

		self.init(id: advertisementData?.localName ?? name, type: type, name: name, localId: peripheral.identifier.uuidString)
	}
}
