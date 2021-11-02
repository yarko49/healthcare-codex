//
//  AnyItemDeletable.swift
//  Allie
//
//  Created by Waqar Malik on 6/9/21.
//

import CareKitStore
import Foundation

public protocol AnyItemDeletable {
	var deletedDate: Date? { get set }
	var effectiveDate: Date { get set }
	var shouldDelete: Bool { get }
	func shouldShow(for date: Date) -> Bool
}

public extension AnyItemDeletable {
	var shouldDelete: Bool {
		guard let date = deletedDate else {
			return false
		}

		return date <= Date()
	}

	func shouldShow(for date: Date) -> Bool {
		guard let deletedDate = deletedDate else {
			return true
		}
		return deletedDate.shouldShow(for: date)
	}

	var isActive: Bool {
		let date = Date()
		if effectiveDate > date {
			return false
		}
		if let deletedDate = deletedDate, deletedDate < date {
			return false
		}
		return true
	}
}

extension Array where Element: AnyItemDeletable {
	var active: [Element] {
		filter { element in
			element.isActive
		}
	}

	var deleted: [Element] {
		filter { element in
			element.shouldDelete
		}
	}
}

extension Date {
	func shouldShow(for date: Date) -> Bool {
		if Calendar.current.isDate(self, inSameDayAs: date) {
			return false
		}

		return self > date
	}
}
