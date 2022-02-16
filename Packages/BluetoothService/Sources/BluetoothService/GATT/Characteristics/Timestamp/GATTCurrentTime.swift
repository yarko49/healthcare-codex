//
//  GATTCurrentTime.swift
//
//
//  Created by Waqar Malik on 2/4/22.
//

import CoreBluetooth
import Foundation

@frozen
public struct GATTCurrentTime: GATTCharacteristic, Equatable {
	public static var rawIdentifier: Int { 0x2A2B }

	internal static let length = GATTExactTime256.length + MemoryLayout<UInt8>.size

	public var exactTime: GATTExactTime256
	public var adjustReason: Flags

	public init(exactTime: GATTExactTime256, adjustReason: Flags) {
		self.exactTime = exactTime
		self.adjustReason = adjustReason
	}

	public init?(data: Data) {
		guard data.count == type(of: self).length else {
			return nil
		}

		guard let exactTime = GATTExactTime256(data: data.subdataNoCopy(in: 0 ..< GATTExactTime256.length)) else {
			return nil
		}

		let adjustReason = Flags(rawValue: data[GATTExactTime256.length])

		self.init(exactTime: exactTime, adjustReason: adjustReason)
	}

	public var data: Data {
		exactTime.data + Data([adjustReason.rawValue])
	}

	public struct Flags: OptionSet, Equatable {
		public static let manualTimeUpdate: Flags = .init(rawValue: 1 << 1)
		public static let externalReference: Flags = .init(rawValue: 1 << 2)
		public static let timeZoneChange: Flags = .init(rawValue: 1 << 3)
		public static let dstChange: Flags = .init(rawValue: 1 << 4)

		public let rawValue: UInt8

		public init(rawValue: UInt8) {
			self.rawValue = rawValue
		}
	}

	public var description: String {
		"Current Time"
	}
}
