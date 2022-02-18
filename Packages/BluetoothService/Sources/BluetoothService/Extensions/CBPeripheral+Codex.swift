//
//  File.swift
//
//
//  Created by Waqar Malik on 2/6/22.
//

import CoreBluetooth
import Foundation

extension CBPeripheral {
	var displayName: String {
		name ?? "Unknown Peripheral"
	}
}
