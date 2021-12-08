//
//  UserDefault.swift
//  Allie
//
//  Created by Waqar Malik on 11/25/21.
//

import Combine
import Foundation

public protocol AnyOptional {
	var isNil: Bool { get }
}

extension Optional: AnyOptional {
	public var isNil: Bool { self == nil }
}

@propertyWrapper
struct UserDefault<Value> {
	let key: String
	let defaultValue: Value
	var container: UserDefaults = .standard
	private let publisher = PassthroughSubject<Value, Never>()

	var wrappedValue: Value {
		get {
			container.object(forKey: key) as? Value ?? defaultValue
		}

		set {
			if let optional = newValue as? AnyOptional, optional.isNil {
				container.removeObject(forKey: key)
			} else {
				container.set(newValue, forKey: key)
			}
		}
	}

	var projectedValue: AnyPublisher<Value, Never> {
		publisher.eraseToAnyPublisher()
	}

	subscript<Value: Codable>(codable: String) -> Value? {
		get {
			guard let data = container.data(forKey: codable) else {
				return nil
			}
			return try? JSONDecoder().decode(Value.self, from: data)
		}
		set {
			guard let encodable = newValue else {
				container.removeObject(forKey: codable)
				return
			}
			let data = try? JSONEncoder().encode(encodable)
			container.setValue(data, forKey: codable)
		}
	}
}
