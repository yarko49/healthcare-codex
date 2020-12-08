//
//  AlfredJSONDecoder.swift
//  alfred-ios
//
//  Created by Waqar Malik on 12/7/20.
//

import Foundation

public final class AlfredJSONDecoder: JSONDecoder {
	let iso8601DateFormatter: ISO8601DateFormatter
	let noTimezoneDateFormatter: DateFormatter

	override init() {
		self.iso8601DateFormatter = ISO8601DateFormatter()
		iso8601DateFormatter.formatOptions.insert(.withFractionalSeconds)

		self.noTimezoneDateFormatter = DateFormatter()
		noTimezoneDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"

		super.init()

		self.dateDecodingStrategy = .custom { [self] (decoder) -> Date in
			let container = try decoder.singleValueContainer()
			let dateString = try container.decode(String.self)
			if let date = self.iso8601DateFormatter.date(from: dateString) ?? self.noTimezoneDateFormatter.date(from: dateString) {
				return date
			} else {
				throw DecodingError.dataCorruptedError(in: container, debugDescription: "Date value is invalid.")
			}
		}
	}
}
