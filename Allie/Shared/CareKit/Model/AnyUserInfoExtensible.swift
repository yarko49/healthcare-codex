//
//  AnyUserInfoExtensible.swift
//  Allie
//
//  Created by Waqar Malik on 3/18/21.
//

import Foundation

protocol AnyUserInfoExtensible {
	var userInfo: [String: String]? { get set }
	mutating func setUserInfo(string: String?, forKey key: String)
	func userInfo(forKey key: String, excludeEmptyString: Bool) -> String?
	mutating func set(bool: Bool, forKey key: String)
	func getBool(forKey key: String) -> Bool
	mutating func set(integer: Int, forKey key: String)
	func getInt(forKey key: String) -> Int
}

extension AnyUserInfoExtensible {
	mutating func setUserInfo(string: String?, forKey key: String) {
		var info = userInfo ?? [:]
		if let value = string {
			info[key] = value
		} else {
			info.removeValue(forKey: key)
		}
		userInfo = info
	}

	func userInfo(forKey key: String, excludeEmptyString: Bool = true) -> String? {
		var value = userInfo?[key]
		if let content = value, content.isEmpty, excludeEmptyString {
			value = nil
		}
		return value
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
