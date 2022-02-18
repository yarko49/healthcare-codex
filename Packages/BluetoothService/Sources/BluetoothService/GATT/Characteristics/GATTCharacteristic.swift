//
//  GATTCharacteristic.swift
//
//
//  Created by Waqar Malik on 2/2/22.
//

import CoreBluetooth
import Foundation

public protocol GATTCharacteristic: GATTIdentifiable, CustomStringConvertible {
	var data: Data { get }

	init?(data: Data)
}
