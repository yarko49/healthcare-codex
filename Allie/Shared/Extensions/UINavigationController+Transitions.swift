//
//  UINavigationController+Transitions.swift
//  Allie
//
//  Created by Waqar Malik on 6/29/21.
//

import UIKit

extension UINavigationController {
	func popViewController(animated: Bool = true, _ completion: (() -> Void)? = nil) {
		// https://github.com/cotkjaer/UserInterface/blob/master/UserInterface/UIViewController.swift
		CATransaction.begin()
		CATransaction.setCompletionBlock(completion)
		popViewController(animated: animated)
		CATransaction.commit()
	}
}
