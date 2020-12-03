//
//  Date+Formatters.swift
//  alfred-ios
//
//  Created by Waqar Malik on 11/26/20.
//

import Foundation

extension DateFormatter {
	// 2020-11-11T01:31:00.343Z
	static let carePlanFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
		formatter.timeZone = TimeZone(secondsFromGMT: 0)
		return formatter
	}()
}
