//
//  AnyUserInfoExtensible.swift
//  Allie
//
//  Created by Waqar Malik on 3/18/21.
//

import Foundation

public protocol AnyUserInfoExtensible {
	var userInfo: [String: String]? { get set }
	mutating func setUserInfo(string: String?, forKey key: String)
	mutating func set(bool: Bool, forKey key: String)
	func getBool(forKey key: String) -> Bool
	mutating func set(integer: Int, forKey key: String)
	func getInt(forKey key: String) -> Int
}

public extension AnyUserInfoExtensible {
	mutating func setUserInfo(string: String?, forKey key: String) {
		var info = userInfo ?? [:]
		if let value = string {
			info[key] = value
			userInfo = info
		} else {
			userInfo?.removeValue(forKey: key)
		}
	}

	mutating func set(bool: Bool, forKey key: String) {
		let boolString = String(bool)
		setUserInfo(string: boolString, forKey: key)
	}

	func getBool(forKey key: String) -> Bool {
		guard let boolString = userInfo?[key] else {
			return false
		}
		return Bool(boolString) ?? false
	}

	mutating func set(integer: Int, forKey key: String) {
		let value = String(integer)
		setUserInfo(string: value, forKey: key)
	}

	func getInt(forKey key: String) -> Int {
		guard let intString = userInfo?[key] else {
			return 0
		}
		return Int(intString) ?? 0
	}
}
