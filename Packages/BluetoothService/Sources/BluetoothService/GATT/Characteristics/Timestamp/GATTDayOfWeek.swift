//
//  GATTDayOfWeek.swift
//
//
//  Created by Waqar Malik on 2/4/22.
//

import CoreBluetooth
import Foundation

@frozen
public struct GATTDayOfWeek: GATTCharacteristic {
	public static var rawIdentifier: Int { 0x2A09 }

	internal static let length = MemoryLayout<UInt8>.size

	public var day: Day

	public init(day: Day) {
		self.day = day
	}

	public init?(data: Data) {
		guard data.count == type(of: self).length else {
			return nil
		}

		guard let day = Day(rawValue: data[0]) else {
			return nil
		}
		self.init(day: day)
	}

	public var data: Data {
		Data([day.rawValue])
	}

	public var description: String {
		"Day of Week"
	}
}

extension GATTDayOfWeek: Equatable {
	public static func == (lhs: GATTDayOfWeek, rhs: GATTDayOfWeek) -> Bool {
		lhs.day == rhs.day
	}
}

public extension GATTDayOfWeek {
	enum Day: UInt8, Hashable, CaseIterable {
		case any = 0
		case monday = 1
		case tuesday = 2
		case wednesday = 3
		case thursday = 4
		case friday = 5
		case saturday = 6
		case sunday = 7
	}
}

extension GATTDayOfWeek.Day: Equatable {
	public static func == (lhs: GATTDayOfWeek.Day, rhs: GATTDayOfWeek.Day) -> Bool {
		lhs.rawValue == rhs.rawValue
	}
}

extension GATTDayOfWeek.Day: CustomStringConvertible {
	public var description: String {
		rawValue.description
	}
}
