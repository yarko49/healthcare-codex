//
//  Date+FHIR.swift
//  Allie
//
//  Created by Waqar Malik on 4/1/21.
//

import Foundation
import ModelsR4

extension Date {
	var r4FHIRDateTime: ModelsR4.DateTime {
		r4FHIRDateTime()
	}

	var r4FHIRPrimitiveDateTime: ModelsR4.FHIRPrimitive<ModelsR4.DateTime> {
		let dateTime = r4FHIRDateTime
		return FHIRPrimitive(dateTime)
	}

	func r4FHIRDateTime(timeZoneString: String? = nil) -> ModelsR4.DateTime {
		let year = Calendar.current.component(.year, from: self)
		let month = Calendar.current.component(.month, from: self)
		let day = Calendar.current.component(.day, from: self)
		let date = ModelsR4.FHIRDate(year: year, month: UInt8(month), day: UInt8(day))

		let hour = Calendar.current.component(.hour, from: self)
		let minute = Calendar.current.component(.minute, from: self)
		let second = Calendar.current.component(.second, from: self)
		let time = ModelsR4.FHIRTime(hour: UInt8(hour), minute: UInt8(minute), second: Decimal(second))
		var timezone = TimeZone.current
		if let value = timeZoneString {
			timezone = TimeZone(abbreviation: value) ?? .current
		}
		return DateTime(date: date, time: time, timezone: timezone)
	}

	func r4FHIRPrimitiveDateTime(timeZoneString: String? = nil) -> ModelsR4.FHIRPrimitive<ModelsR4.DateTime> {
		let dateTime = r4FHIRDateTime(timeZoneString: timeZoneString)
		return FHIRPrimitive(dateTime)
	}
}
