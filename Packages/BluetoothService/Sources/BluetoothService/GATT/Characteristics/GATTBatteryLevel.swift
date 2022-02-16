//
//  File.swift
//
//
//  Created by Waqar Malik on 2/6/22.
//

import Foundation

@frozen
public struct GATTBatteryLevel: GATTCharacteristic, Equatable, Hashable {
	public static var rawIdentifier: Int { 0x2A19 }

	internal static let length = MemoryLayout<UInt8>.size

	public let level: Int
	public let data: Data

	public init?(data: Data) {
		guard data.count >= type(of: self).length else {
			return nil
		}

		self.data = data
		self.level = Int(data[0])
	}

	public var description: String {
		"Battery Level"
	}
}
