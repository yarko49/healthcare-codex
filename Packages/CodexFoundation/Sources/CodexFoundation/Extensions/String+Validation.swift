//
//  String+Validation.swift
//  Allie
//

import Foundation

public extension String {
	func isValidEmail() -> Bool {
		let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
		let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
		return emailPred.evaluate(with: self)
	}

	func isValidText() -> Bool {
		let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ ")
		return rangeOfCharacter(from: characterset.inverted) == nil
	}
}

public extension String {
	var cf_isValidEmail: Bool {
		guard let dataDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
			return false
		}
		let range = NSRange(location: 0, length: count)
		let matches = dataDetector.matches(in: self, options: .reportCompletion, range: range)
		guard let firstMatch = matches.first, firstMatch.resultType == .link, firstMatch.url?.scheme == "mailto", firstMatch.range == range else {
			return false
		}
		return true
	}
}

public extension Optional where Wrapped == String {
	var cf_isValidEmail: Bool {
		guard let email = self else {
			return false
		}
		return email.cf_isValidEmail
	}
}
