//
//  Date+Conversion.swift
//  Allie
//
//  Created by Waqar Malik on 5/8/21.
//

import Foundation

extension Date {
	var toUTC: Date {
		let timezone = TimeZone.current
		let seconds = -TimeInterval(timezone.secondsFromGMT(for: self))
		return Date(timeInterval: seconds, since: self)
	}

	// Convert UTC (or GMT) to local time
	var toLocalTime: Date {
		// 1) Get the current TimeZone's seconds from GMT. Since I am in Chicago this will be: 60*60*5 (18000)
		let timezoneOffset = TimeZone.current.secondsFromGMT()

		// 2) Get the current date (GMT) in seconds since 1970. Epoch datetime.
		let epochDate = timeIntervalSince1970

		// 3) Perform a calculation with timezoneOffset + epochDate to get the total seconds for the
		//    local date since 1970.
		//    This may look a bit strange, but since timezoneOffset is given as -18000.0, adding epochDate and timezoneOffset
		//    calculates correctly.
		let timezoneEpochOffset = (epochDate + Double(timezoneOffset))

		// 4) Finally, create a date using the seconds offset since 1970 for the local date.
		return Date(timeIntervalSince1970: timezoneEpochOffset)
	}

	var byUpdatingTimeToNow: Date {
		dateByMatching(matchingTime: Date())
	}

	static func dateByMatching(date: Date, matchingTime toDate: Date) -> Date {
		let calendar = Calendar.current
		let days = calendar.dateComponents([.day], from: toDate, to: date)
		let updatedDate = calendar.date(byAdding: .day, value: days.day!, to: toDate)
		return updatedDate ?? date
	}

	func dateByMatching(matchingTime toDate: Date) -> Date {
		let calendar = Calendar.current
		let days = calendar.dateComponents([.day], from: toDate, to: self)
		let updatedDate = calendar.date(byAdding: .day, value: days.day!, to: toDate)
		return updatedDate ?? self
	}
}
