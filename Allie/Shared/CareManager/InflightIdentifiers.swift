//
//  InflightIdentifiers.swift
//  Allie
//
//  Created by Waqar Malik on 8/1/21.
//

import Foundation
import HealthKit

struct InflightIdentifers<IdentifierType: Hashable> {
	private let lock = ReadWriteLock()
	private var identifiers: Set<IdentifierType> = []

	mutating func insert(_ newMember: IdentifierType) {
		lock.writeLock()
		identifiers.insert(newMember)
		lock.unlock()
	}

	mutating func remove(_ member: IdentifierType) -> IdentifierType? {
		lock.writeLock()
		let value = identifiers.remove(member)
		lock.unlock()
		return value
	}

	func contains(_ member: IdentifierType) -> Bool {
		lock.readLock()
		let contains = identifiers.contains(member)
		lock.unlock()
		return contains
	}
}
