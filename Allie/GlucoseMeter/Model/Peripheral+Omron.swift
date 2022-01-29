//
//  Peripheral+Omron.swift
//  Allie
//
//  Created by Waqar Malik on 1/27/22.
//

import BluetoothService
import Foundation
import OmronKit

extension Peripheral {
	var omronDeviceDiscoveryInfo: OHQDeviceDiscoveryInfo? {
		OHQDeviceDiscoveryInfo(peripheral: peripheral, rawAdvertisementData: advertisementData.advertisementData, rssi: rssi)
	}
}
