//
//  ViewNIBLoading.swift
//  Allie
//
//  Created by Waqar Malik on 1/1/21.
//

import UIKit

protocol ViewNIBLoading {
	static var nibName: String { get }
}

extension ViewNIBLoading {
	static var nibName: String {
		String(describing: self)
	}
}

extension UIView: ViewNIBLoading {}
