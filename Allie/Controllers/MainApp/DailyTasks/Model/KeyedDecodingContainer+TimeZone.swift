//
//  KeyedDecodingContainer+TimeZone.swift
//  Allie
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
}
