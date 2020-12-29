//
//  Ext_DateFormatter.swift
//  Alfred
//

import Foundation

extension DateFormatter {
	static var yyyyMMddTHHmmssDashed: DateFormatter {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
		return formatter
	}

	static var wholeDate: DateFormatter {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
		return formatter
	}

	static var iso8601: DateFormatter {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS+'Z'"
		return formatter
	}

	static var wholeDateRequest: DateFormatter {
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
		return formatter
	}

	static var wholeDateNoTimeZoneRequest: DateFormatter {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
		return formatter
	}

	static var MMMdd: DateFormatter {
		let formatter = DateFormatter()
		formatter.dateFormat = "MMM dd"
		return formatter
	}

	static var yyyy: DateFormatter {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy"
		return formatter
	}

	static var ddMMyyyy: DateFormatter {
		let formatter = DateFormatter()
		formatter.dateFormat = "MMMM dd, YYYY"
		return formatter
	}

	static var yyyyMMdd: DateFormatter {
		let formatter = DateFormatter()
		formatter.dateFormat = "YYYY-MM-dd"
		return formatter
	}

	static var hmma: DateFormatter {
		let formatter = DateFormatter()
		formatter.dateFormat = "h:mm a"
		return formatter
	}
}
