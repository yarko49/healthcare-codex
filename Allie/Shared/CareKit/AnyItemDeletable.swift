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
}

public extension AnyItemDeletable {
	var shouldDelete: Bool {
		guard let date = deletedDate else {
			return false
		}

		return date <= Date()
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
