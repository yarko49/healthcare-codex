//
//  String+Sanitize.swift
//
//
//  Created by Waqar Malik on 2/17/22.
//

import Foundation

public extension String {
	var cf_sanitized: String {
		cf_sanitized()
	}

	func cf_sanitized(characterSet: CharacterSet = .alphanumerics) -> String {
		String(unicodeScalars.filter { characterSet.contains($0) })
	}
}
