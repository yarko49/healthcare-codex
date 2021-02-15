//
//  Keychain+Auth.swift
//  Allie
//
//  Created by Waqar Malik on 1/31/21.
//

import Foundation

extension Keychain {
	enum KeychainKey: String {
		case authToken = "AUTH_TOKEN"
		case emailForLink = "EMAIL_FOR_LINK"
	}

	class var authToken: String? {
		get {
			Self[KeychainKey.authToken.rawValue]
		}
		set {
			Self[KeychainKey.authToken.rawValue] = newValue
		}
	}

	class var emailForLink: String? {
		get {
			Self[KeychainKey.emailForLink.rawValue]
		}
		set {
			Self[KeychainKey.emailForLink.rawValue] = newValue
		}
	}

	class func clearKeychain() {
		Self.logout()
	}
}
