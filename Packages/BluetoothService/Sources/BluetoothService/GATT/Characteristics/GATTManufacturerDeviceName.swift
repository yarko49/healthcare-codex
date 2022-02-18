//
//  GATTManufacturerDeviceName.swift
//
//
//  Created by Waqar Malik on 2/6/22.
//

import Foundation

@frozen
public struct GATTManufacturerDeviceName: GATTCharacteristic {
	public static var rawIdentifier: Int { 0x2A00 }

	public var data: Data

	public init?(data: Data) {
		self.data = data
	}

	public var description: String {
		"Manufacturer Device Name"
	}
}
