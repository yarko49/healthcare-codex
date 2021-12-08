//
//  KeychainStorage.swift
//  Allie
//
//  Created by Waqar Malik on 11/26/21.
//

import KeychainAccess
import SwiftUI

@propertyWrapper
struct KeychainStorage<T: Codable>: DynamicProperty {
	typealias Value = T
	let key: String
	@State private var value: Value?
	@Injected(\.keychain) var keychain: Keychain

	init(wrappedValue: Value? = nil, _ key: String) {
		self.key = key
		let initialValue: T? = keychain[codable: key] ?? wrappedValue
		self._value = State<Value?>(initialValue: initialValue)
	}

	var wrappedValue: Value? {
		get { value }

		nonmutating set {
			value = newValue
			keychain[codable: key] = newValue
		}
	}

	var projectedValue: Binding<Value?> {
		Binding(get: { wrappedValue }, set: { wrappedValue = $0 })
	}
}
