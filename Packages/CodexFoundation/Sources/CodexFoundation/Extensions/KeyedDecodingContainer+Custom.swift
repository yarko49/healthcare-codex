//
//  KeyedDecodingContainer+TimeZone.swift
//  Allie
//
//  Created by Waqar Malik on 12/6/20.
//

import Foundation
import os.log

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

public extension KeyedDecodingContainer {
	func safelyDecodeArray<T: Decodable, A: Decodable>(of type: T.Type, alternate: A.Type, forKey key: KeyedDecodingContainer.Key) -> ([T], [A]) {
		guard var container = try? nestedUnkeyedContainer(forKey: key) else {
			return ([], [])
		}
		var elements: [T] = []
		var alternates: [A] = []

		elements.reserveCapacity(container.count ?? 0)
		while !container.isAtEnd {
			do {
				elements.append(try container.decode(T.self))
			} catch {
				if let decodingError = error as? DecodingError {
					os_log(.error, "%@: skipping one element: %@", #function, decodingError as NSError)
				} else {
					os_log(.error, "$@: skipping one element: ", #function, error as NSError)
				}
				if let item = try? container.decode(A.self) {
					alternates.append(item)
				}
			}
		}
		return (elements, alternates)
	}
}
