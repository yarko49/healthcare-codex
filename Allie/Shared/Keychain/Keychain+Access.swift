//
//  Keychain+Access.swift
//  Allie
//
//  Created by Waqar Malik on 5/23/21.
//

import CodexModel
import Foundation
import KeychainAccess

extension Keychain {
	subscript<T: Codable>(codable key: String) -> T? {
		get {
			read(forKey: key)
		}
		set {
			save(value: newValue, forKey: key)
		}
	}

	func read<T: Decodable>(forKey key: String) -> T? {
		guard let data = self[data: key] else {
			return nil
		}
		do {
			let decoder = JSONDecoder()
			decoder.dateDecodingStrategy = .iso8601
			let value = try decoder.decode(T.self, from: data)
			return value
		} catch {
			ALog.error("\(error.localizedDescription)")
			return nil
		}
	}

	func save<T: Encodable>(value: T?, forKey key: String) {
		guard let value = value else {
			try? remove(key)
			return
		}
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .iso8601
		do {
			let data = try encoder.encode(value)
			try set(data, key: key)
		} catch {
			ALog.error("\(error.localizedDescription)")
		}
	}

	func clearKeychain() {
		try? removeAll()
	}
}

extension Keychain {
	enum Keys {
		static let authenticationToken = "AuthenticationToken"
		static let userEmail = "UserEmail"
		static let userIdentifier = "UserIdentifier"
		static let fcmToken = "fcmToken"
		static let organizations = "organizations"
	}

	var userIdentifier: String? {
		get {
			self[Keys.userIdentifier]
		}
		set {
			self[Keys.userIdentifier] = newValue
		}
	}

	var userEmail: String? {
		get {
			self[Keys.userEmail]
		}
		set {
			self[Keys.userEmail] = newValue
		}
	}

	var patient: CHPatient? {
		get {
			guard let userId = userIdentifier else {
				return nil
			}
			let patient: CHPatient? = read(forKey: userId)
			return patient
		}
		set {
			guard let userId = newValue?.id else {
				return
			}
			userIdentifier = userId
			save(value: newValue, forKey: userId)
		}
	}

	var authenticationToken: AuthenticationToken? {
		get {
			self[codable: Keys.authenticationToken]
		}
		set {
			self[codable: Keys.authenticationToken] = newValue
		}
	}

	var fcmToken: String? {
		get {
			self[Keys.fcmToken]
		}
		set {
			self[Keys.fcmToken] = newValue
		}
	}

	var organizations: CMOrganizations? {
		get {
			self[codable: Keys.organizations]
		}
		set {
			self[codable: Keys.organizations] = newValue
		}
	}
}
