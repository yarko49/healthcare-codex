//
//  File.swift
//
//
//  Created by Waqar Malik on 2/16/22.
//

import Foundation

@frozen
public struct GATTWeightMeasurement: GATTCharacteristic {
	public static var rawIdentifier: Int { 0x2A9D }

	internal static let length: Int = MemoryLayout<UInt32>.size

	public var data: Data

	public init?(data: Data) {
		self.data = data
	}

	public var description: String {
		"Weight Measurement"
	}
}
