//
//  InflightIdentifiers.swift
//  Allie
//
//  Created by Waqar Malik on 8/1/21.
//

import Foundation

public struct InflightIdentifers<IdentifierType: Hashable> {
	private let lock = ReadWriteLock()
	private var identifiers: Set<IdentifierType> = []

	public init() {}

	public mutating func insert(_ newMember: IdentifierType) {
		lock.writeLock()
		identifiers.insert(newMember)
		lock.unlock()
	}

	public mutating func remove(_ member: IdentifierType) -> IdentifierType? {
		lock.writeLock()
		let value = identifiers.remove(member)
		lock.unlock()
		return value
	}

	public func contains(_ member: IdentifierType) -> Bool {
		lock.readLock()
		let contains = identifiers.contains(member)
		lock.unlock()
		return contains
	}
}
