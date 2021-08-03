//
//  InflightIdentifiers.swift
//  Allie
//
//  Created by Waqar Malik on 8/1/21.
//

import Foundation
import HealthKit

struct InflightIdentifers {
	private let lock = ReadWriteLock()
	private var identifiers: Set<HKQuantityTypeIdentifier> = []

	mutating func insert(_ newMember: HKQuantityTypeIdentifier) {
		lock.writeLock()
		identifiers.insert(newMember)
		lock.unlock()
	}

	mutating func remove(_ member: HKQuantityTypeIdentifier) -> HKQuantityTypeIdentifier? {
		lock.writeLock()
		let value = identifiers.remove(member)
		lock.unlock()
		return value
	}

	func contains(_ member: HKQuantityTypeIdentifier) -> Bool {
		lock.readLock()
		let contains = identifiers.contains(member)
		lock.unlock()
		return contains
	}
}
