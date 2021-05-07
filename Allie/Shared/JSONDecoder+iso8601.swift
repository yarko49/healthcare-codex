//
//  JSONDecoder+iso8601.swift
//  Allie
//
//  Created by Waqar Malik on 5/4/21.
//

import Foundation

extension JSONDecoder.DateDecodingStrategy {
	static let standardFormats = custom { decoder -> Date in
		let container = try decoder.singleValueContainer()
		let dateString = try container.decode(String.self)
		if let date = Formatter.iso8601WithFractionalSeconds.date(from: dateString) ?? DateFormatter.wholeDateRequest.date(from: dateString) ?? DateFormatter.wholeDateNoTimeZoneRequest.date(from: dateString) {
			return date
		} else {
			throw DecodingError.dataCorruptedError(in: container, debugDescription: "Date value is invalid. \(dateString)")
		}
	}

	static let iso8601WithFractionalSeconds = custom { decoder -> Date in
		let container = try decoder.singleValueContainer()
		let dateString = try container.decode(String.self)
		if let date = Formatter.iso8601WithFractionalSeconds.date(from: dateString) {
			return date
		} else {
			throw DecodingError.dataCorruptedError(in: container, debugDescription: "Date value is invalid. \(dateString)")
		}
	}

	static let rfc3339 = custom { decoder -> Date in
		let container = try decoder.singleValueContainer()
		let dateString = try container.decode(String.self)
		if let date = DateFormatter.wholeDateRequest.date(from: dateString) ?? DateFormatter.wholeDateNoTimeZoneRequest.date(from: dateString) {
			return date
		} else {
			throw DecodingError.dataCorruptedError(in: container, debugDescription: "Date value is invalid. \(dateString)")
		}
	}
}
