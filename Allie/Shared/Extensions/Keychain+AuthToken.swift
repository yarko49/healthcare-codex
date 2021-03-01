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
		case userIdentifier = "UserIdentifier"
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

	class var patientID: String? {
		"Patient/\(userId ?? "")"
	}

	class var userId: String? {
		get {
			Self[KeychainKey.userIdentifier.rawValue]
		}
		set {
			Self[KeychainKey.userIdentifier.rawValue] = newValue
		}
	}

	class func clearKeychain() {
		Self.logout()
	}
}
