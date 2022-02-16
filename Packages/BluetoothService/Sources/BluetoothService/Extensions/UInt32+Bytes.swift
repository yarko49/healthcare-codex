//
//  File.swift
//
//
//  Created by Waqar Malik on 2/3/22.
//

import Foundation

internal extension UInt32 {
	// swiftlint:disable:next large_tuple
	init(bytes: (UInt8, UInt8, UInt8, UInt8)) {
		self = unsafeBitCast(bytes, to: UInt32.self)
	}

	// swiftlint:disable:next large_tuple
	var bytes: (UInt8, UInt8, UInt8, UInt8) {
		return unsafeBitCast(self, to: (UInt8, UInt8, UInt8, UInt8).self)
	}
}
