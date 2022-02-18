//
//  GATTDateTime.swift
//
//
//  Created by Waqar Malik on 2/2/22.
//

import CoreBluetooth
import Foundation

@frozen
public struct GATTDateTime: GATTCharacteristic {
	public static var rawIdentifier: Int { 0x2A08 }

	internal static let length: Int = 10

	public let data: Data

	public let year: UInt16
	public let month: UInt8
	public let day: UInt8
	public let hour: UInt8
	public let minute: UInt8
	public let second: UInt8
	public let weekday: UInt8
	public let fraction256: UInt8

	public init?(data: Data) {
		guard data.count == type(of: self).length else {
			return nil
		}
		self.data = data

		self.year = UInt16(littleEndian: UInt16(bytes: (data[0], data[1])))
		self.month = data[2]
		self.day = data[3]
		self.hour = data[4]
		self.minute = data[5]
		self.second = data[6]
		self.weekday = data[7]
		self.fraction256 = data[8]
	}

	public init(date: Date, calendar: Calendar = .current) {
		let components = calendar.dateComponents([.day, .month, .year, .hour, .minute, .second, .weekday, .nanosecond], from: date)
		let timezone = calendar.component(.timeZone, from: date)
		let isDST = calendar.timeZone.isDaylightSavingTime()
		self.init(dateComponents: components, timezone: timezone, isDST: isDST)
	}

	public init(dateComponents components: DateComponents, timezone: Int, isDST: Bool) {
		let milisecond = components.nanosecond! / 1000000
		self.fraction256 = UInt8(milisecond / 256)
		self.year = UInt16(components.year!)
		let year_mso = components.year! & 0xFF
		let year_lso = (components.year! >> 8) & 0xFF
		let adjust_reason = 1

		let year_MSO = UInt8(year_mso)
		let year_LSO = UInt8(year_lso)
		self.month = UInt8(components.month!)
		self.day = UInt8(components.day!)
		self.hour = UInt8(components.hour!)
		self.minute = UInt8(components.minute!)
		self.second = UInt8(components.second!)
		self.weekday = UInt8(components.weekday!)
		let adjust = UInt8(adjust_reason)

		let currentTimeArray = [year_MSO, year_LSO, month, day, hour, minute, second, weekday, fraction256, adjust]
		self.data = Data(currentTimeArray)
	}

	public var date: Date? {
		let valueArray = [UInt8](data)
		let year = Int(UInt16(littleEndian: UInt16(bytes: (valueArray[0], valueArray[1]))))
		let month = Int(valueArray[2])
		let day = Int(valueArray[3])
		let hour = Int(valueArray[4])
		let minutes = Int(valueArray[5])
		let seconds = Int(valueArray[6])
		let weekday = Int(valueArray[7])
		let nanosecond = (Int(valueArray[8]) * 256) * 1000000
		let components = DateComponents(year: year, month: month, day: day, hour: hour, minute: minutes, second: seconds, nanosecond: nanosecond, weekday: weekday)
		return Calendar.current.date(from: components)
	}

	public var description: String {
		"Date & Time"
	}
}

extension GATTDateTime: Equatable {
	public static func == (lhs: GATTDateTime, rhs: GATTDateTime) -> Bool {
		lhs.data == rhs.data
	}
}

public extension GATTDateTime {
	enum Month: UInt8, Hashable, CaseIterable {
		case unknown = 0
		case january
		case february
		case march
		case april
		case may
		case june
		case july
		case august
		case september
		case october
		case november
		case december
	}
}
