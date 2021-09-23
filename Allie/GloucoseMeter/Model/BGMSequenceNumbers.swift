//
//  BGMSequenceNumbers.swift
//  Allie
//
//  Created by Waqar Malik on 9/20/21.
//

import Foundation

struct BGMSequenceNumbers<Element> where Element: Hashable & Comparable {
	private var sequenceNumbers: [String: Set<Element>] = [:]

	var isEmpty: Bool {
		sequenceNumbers.isEmpty
	}

	mutating func insert(value: Element, forDevice deviceId: String) {
		var existing = sequenceNumbers[deviceId] ?? []
		existing.update(with: value)
		sequenceNumbers[deviceId] = existing
	}

	mutating func remove(value: Element, forDevice deviceId: String) -> Element? {
		guard var values = sequenceNumbers[deviceId] else {
			return nil
		}

		let value = values.remove(value)
		sequenceNumbers[deviceId] = values
		return value
	}

	mutating func insert(values: Set<Element>, forDevice deviceId: String) {
		var existing = sequenceNumbers[deviceId] ?? []
		existing.formUnion(values)
		sequenceNumbers[deviceId] = existing
	}

	mutating func formUnion(_ newNumbers: BGMSequenceNumbers) {
		guard !newNumbers.isEmpty else {
			return
		}
		newNumbers.sequenceNumbers.forEach { (key: String, value: Set<Element>) in
			insert(values: value, forDevice: key)
		}
	}

	func contains(number: Element, forDevice deviceId: String) -> Bool {
		guard let values = sequenceNumbers[deviceId] else {
			return false
		}
		return values.contains(number)
	}

	func max(forDevice deviceId: String) -> Element? {
		guard let values = sequenceNumbers[deviceId] else {
			return nil
		}
		return values.max()
	}

	mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
		sequenceNumbers.removeAll(keepingCapacity: keepCapacity)
	}
}
