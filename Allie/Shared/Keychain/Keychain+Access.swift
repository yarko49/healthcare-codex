//
//  Keychain+Access.swift
//  Allie
//
//  Created by Waqar Malik on 5/23/21.
//

import Foundation
import KeychainAccess

extension Keychain {
	static let shared = Keychain(service: AppConfig.appBundleID)

	subscript<T: Codable>(codable key: String) -> T? {
		get {
			read(forKey: key)
		}
		set {
			save(value: newValue, forKey: key)
		}
	}

	func read<T: Decodable>(forKey key: String) -> T? {
		guard let data = Self.shared[data: key] else {
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
			try? Self.shared.remove(key)
			return
		}
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .iso8601
		do {
			let data = try encoder.encode(value)
			try Self.shared.set(data, key: key)
		} catch {
			ALog.error("\(error.localizedDescription)")
		}
	}

	static func clearKeychain() {
		try? Self.shared.removeAll()
	}
}

extension Keychain {
	enum Keys {
		static let authenticationToken = "AuthenticationToken"
		static let userEmail = "UserEmail"
		static let userIdentifier = "UserIdentifier"
		static let fcmToken = "fcmToken"
	}

	static var userIdentifier: String? {
		get {
			Self.shared[Keys.userIdentifier]
		}
		set {
			Self.shared[Keys.userIdentifier] = newValue
		}
	}

	static var userEmail: String? {
		get {
			Self.shared[Keys.userEmail]
		}
		set {
			Self.shared[Keys.userEmail] = newValue
		}
	}

	static var patient: CHPatient? {
		get {
			guard let userId = Self.userIdentifier else {
				return nil
			}
			let patient: CHPatient? = Self.shared.read(forKey: userId)
			return patient
		}
		set {
			guard let userId = newValue?.id else {
				return
			}
			Self.userIdentifier = userId
			Self.shared.save(value: newValue, forKey: userId)
		}
	}

	static var authenticationToken: AuthenticationToken? {
		get {
			Self.shared[codable: Keys.authenticationToken]
		}
		set {
			Self.shared[codable: Keys.authenticationToken] = newValue
		}
	}

	static var fcmToken: String? {
		get {
			Self.shared[Keys.fcmToken]
		}
		set {
			Self.shared[Keys.fcmToken] = newValue
		}
	}
}
