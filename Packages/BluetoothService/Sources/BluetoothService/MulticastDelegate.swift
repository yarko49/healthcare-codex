//
//  File.swift
//
//
//  Created by Waqar Malik on 12/10/21.
//

import Foundation

final class MulticastDelegate<T> {
	private let delegates: NSHashTable<AnyObject> = NSHashTable.weakObjects()

	deinit {
		delegates.removeAllObjects()
	}
}

extension MulticastDelegate {
	func add(_ delegate: T) {
		delegates.add(delegate as AnyObject)
	}

	func remove(_ delegateToRemove: T) {
		for delegate in delegates.allObjects.reversed() {
			// swiftlint:disable:next for_where
			if delegate === delegateToRemove as AnyObject {
				delegates.remove(delegate)
			}
		}
	}

	func invoke(_ invocation: (T?) -> Void) {
		for delegate in delegates.allObjects.reversed() {
			invocation(delegate as? T)
		}
	}
}
