//
//  TaskViewUpdatable.swift
//  Allie
//
//  Created by Waqar Malik on 10/26/21.
//

import UIKit

protocol TaskViewUpdatable {
	associatedtype ViewType: UIView

	var items: [ViewType] { get }

	func makeItem(value: String?, time: String?, context: String?, canEdit: Bool) -> ViewType
	func updateItem(at index: Int, value: String?, time: String?, context: String?) -> ViewType?
	func insertItem(value: String?, time: String?, context: String?, at index: Int, animated: Bool, canEdit: Bool) -> ViewType
	func appendItem(value: String?, time: String?, context: String?, animated: Bool, canEdit: Bool) -> ViewType
	func removeItem(at index: Int, animated: Bool) -> ViewType?
}
