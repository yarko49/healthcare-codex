//
//  JSONEncoder+iso8601.swift
//  Allie
//
//  Created by Waqar Malik on 5/4/21.
//

import Foundation

public extension JSONEncoder.DateEncodingStrategy {
	static let iso8601WithFractionalSeconds = custom { date, encoder in
		var container = encoder.singleValueContainer()
		try container.encode(Formatter.iso8601WithFractionalSeconds.string(from: date))
	}

	static let rfc3339 = custom { date, encoder in
		var container = encoder.singleValueContainer()
		try container.encode(DateFormatter.wholeDateRequest.string(from: date))
	}
}
