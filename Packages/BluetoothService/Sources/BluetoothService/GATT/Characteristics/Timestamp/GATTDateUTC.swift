//
//  GATTDateUTC.swift
//
//
//  Created by Waqar Malik on 2/6/22.
//

import Foundation

@frozen
public struct GATTDateUTC: GATTCharacteristic {
	public static var rawIdentifier: Int { 0x2AED }

	internal static let length = MemoryLayout<UInt8>.size + MemoryLayout<UInt8>.size + MemoryLayout<UInt8>.size

	public let data: Data

	public init?(data: Data) {
		self.data = data
	}

	public var description: String {
		"UTC Date"
	}
}
