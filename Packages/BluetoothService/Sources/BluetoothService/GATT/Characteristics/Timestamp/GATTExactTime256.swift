//
//  GATTExactTime256.swift
//
//
//  Created by Waqar Malik on 2/4/22.
//

import CoreBluetooth
import Foundation

@frozen
public struct GATTExactTime256: GATTCharacteristic {
	public static var rawIdentifier: Int { 0x2A0C }

	internal static let length = GATTDayDateTime.length + MemoryLayout<UInt8>.size

	public var dayDateTime: GATTDayDateTime

	public var fractions256: UInt8

	public init(dayDateTime: GATTDayDateTime, fractions256: UInt8) {
		self.dayDateTime = dayDateTime
		self.fractions256 = fractions256
	}

	public init?(data: Data) {
		guard data.count == type(of: self).length else {
			return nil
		}

		guard let dayDateTime = GATTDayDateTime(data: data.subdataNoCopy(in: 0 ..< GATTDayDateTime.length)) else {
			return nil
		}

		let fractions256 = data[GATTDayDateTime.length]
		self.init(dayDateTime: dayDateTime, fractions256: fractions256)
	}

	public var data: Data {
		dayDateTime.data + Data([fractions256])
	}

	public var description: String {
		"Exact Time"
	}
}

extension GATTExactTime256: Equatable {
	public static func == (lhs: GATTExactTime256, rhs: GATTExactTime256) -> Bool {
		lhs.dayDateTime == rhs.dayDateTime &&
			lhs.fractions256 == rhs.fractions256
	}
}
