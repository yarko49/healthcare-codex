//
//  File.swift
//
//
//  Created by Waqar Malik on 2/12/22.
//

import Foundation

public extension String {
	var dataFromHex: Data? {
		let stringArray = Array(self)
		var data = Data()
		for index in stride(from: 0, to: count, by: 2) {
			let pair = String(stringArray[index]) + String(stringArray[index + 1])
			if let byteNum = UInt8(pair, radix: 16) {
				let byte = Data([byteNum])
				data.append(byte)
			} else {
				return nil
			}
		}
		return data
	}
}
