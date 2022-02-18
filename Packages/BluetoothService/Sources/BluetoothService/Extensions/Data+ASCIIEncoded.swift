//
//  File.swift
//
//
//  Created by Waqar Malik on 2/6/22.
//

import Foundation

extension Data {
	var asciiEncodedString: String? {
		String(data: self, encoding: .ascii)
	}
}
