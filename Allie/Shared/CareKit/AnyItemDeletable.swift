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
}

public extension AnyItemDeletable {
	var shouldDelete: Bool {
		guard let date = deletedDate else {
			return false
		}

		return date <= Date()
	}
}
