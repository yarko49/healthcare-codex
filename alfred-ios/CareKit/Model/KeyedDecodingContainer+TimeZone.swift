//
//  KeyedDecodingContainer+TimeZone.swift
//  alfred-ios
//
//  Created by Waqar Malik on 12/6/20.
//

import Foundation

public extension KeyedDecodingContainer {
	func decodeTimeZone(forKey key: KeyedDecodingContainer<K>.Key) throws -> TimeZone {
		let timezoneSeconds: Int = try decode(Int.self, forKey: key)
		if let timezone = TimeZone(secondsFromGMT: timezoneSeconds) {
			return timezone
		} else {
			throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "Timezone value is invalid.")
		}
	}

	func decodeDate(forKey key: KeyedDecodingContainer<K>.Key) throws -> Date {
		let dateString = try decode(String.self, forKey: key)
		if let date = DateFormatter.wholeDateRequest.date(from: dateString) ?? DateFormatter.wholeDateNoTimeZoneRequest.date(from: dateString) {
			return date
		} else {
			throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "Date value is invalid.")
		}
	}

	func decodeDateIfPresent(forKey key: KeyedDecodingContainer<K>.Key) throws -> Date? {
		guard let dateString = try decodeIfPresent(String.self, forKey: key) else {
			return nil
		}
		let date = DateFormatter.wholeDateRequest.date(from: dateString) ?? DateFormatter.wholeDateNoTimeZoneRequest.date(from: dateString)
		return date
	}
}
