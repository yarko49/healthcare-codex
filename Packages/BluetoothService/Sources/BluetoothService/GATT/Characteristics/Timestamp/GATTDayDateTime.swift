//
//  GATTDayDateTime.swift
//
//
//  Created by Waqar Malik on 2/4/22.
//

import CoreBluetooth
import Foundation

@frozen
public struct GATTDayDateTime: GATTCharacteristic {
	public static var rawIdentifier: Int { 0x2A0A }

	internal static let length = GATTDateTime.length + GATTDayOfWeek.length

	public var dateTime: GATTDateTime
	public var dayOfWeek: GATTDayOfWeek

	public init(dateTime: GATTDateTime, dayOfWeek: GATTDayOfWeek) {
		self.dateTime = dateTime
		self.dayOfWeek = dayOfWeek
	}

	public init?(data: Data) {
		guard data.count == type(of: self).length else {
			return nil
		}

		guard let dateTime = GATTDateTime(data: data.subdataNoCopy(in: 0 ..< 7)) else {
			return nil
		}

		guard let dayOfWeek = GATTDayOfWeek(data: data.subdataNoCopy(in: 7 ..< 8)) else {
			return nil
		}

		self.init(dateTime: dateTime, dayOfWeek: dayOfWeek)
	}

	public var data: Data {
		dateTime.data + dayOfWeek.data
	}

	public var description: String {
		"Day, Date & Time"
	}
}

extension GATTDayDateTime: Equatable {
	public static func == (lhs: GATTDayDateTime, rhs: GATTDayDateTime) -> Bool {
		lhs.dateTime == rhs.dateTime && lhs.dayOfWeek == rhs.dayOfWeek
	}
}
