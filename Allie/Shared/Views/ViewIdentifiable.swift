//
//  ViewIdentifiable.swift
//  Allie
//
//  Created by Waqar Malik on 1/1/21.
//

import UIKit

protocol ViewIdentifiable {
	static var reuseIdentifier: String { get }
}

extension ViewIdentifiable {
	static var reuseIdentifier: String {
		String(describing: self)
	}
}

extension UITableViewCell: ViewIdentifiable {}
extension UITableViewHeaderFooterView: ViewIdentifiable {}
extension UICollectionReusableView: ViewIdentifiable {}
