//
//  InjectedValues.swift
//  Allie
//
//  Created by Waqar Malik on 8/15/21.
//

import Foundation

public protocol InjectionKey {
	/// The associated type representing the type of the dependency injection key's value.
	associatedtype Value

	/// The default value for the dependency injection key.
	static var currentValue: Self.Value { get set }
}

/// Provides access to injected dependencies.
public struct InjectedValues {
	/// This is only used as an accessor to the computed properties within extensions of `InjectedValues`.
	private static var current = InjectedValues()

	/// A static subscript for updating the `currentValue` of `InjectionKey` instances.
	public static subscript<K>(key: K.Type) -> K.Value where K: InjectionKey {
		get { key.currentValue }
		set { key.currentValue = newValue }
	}

	/// A static subscript accessor for updating and references dependencies directly.
	public static subscript<T>(_ keyPath: WritableKeyPath<InjectedValues, T>) -> T {
		get { current[keyPath: keyPath] }
		set { current[keyPath: keyPath] = newValue }
	}
}
