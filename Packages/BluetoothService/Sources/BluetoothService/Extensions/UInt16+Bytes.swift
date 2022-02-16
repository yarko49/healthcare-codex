//
//  File.swift
//
//
//  Created by Waqar Malik on 2/3/22.
//

import Foundation

internal extension UInt16 {
	/// Initializes value from two bytes.
	init(bytes: (UInt8, UInt8)) {
		self = unsafeBitCast(bytes, to: UInt16.self)
	}

	/// Converts to two bytes.
	var bytes: (UInt8, UInt8) {
		return unsafeBitCast(self, to: (UInt8, UInt8).self)
	}
}
