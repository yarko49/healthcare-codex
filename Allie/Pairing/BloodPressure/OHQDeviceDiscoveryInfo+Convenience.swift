//
//  OHQDeviceDiscoveryInfo+Convenience.swift
//  Allie
//
//  Created by Waqar Malik on 1/27/22.
//

import BluetoothService
import Foundation
import OmronKit

extension OHQDeviceDiscoveryInfo {
	convenience init(peripheral: Peripheral) {
		self.init(peripheral: peripheral.peripheral, rawAdvertisementData: peripheral.advertisementData.advertisementData, rssi: peripheral.rssi)
	}
}
