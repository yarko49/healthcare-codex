//
//  BaseCoordinator.swift
//  Allie
//
//  Created by Waqar Malik on 5/24/21.
//

import Combine
import LocalAuthentication
import UIKit

class BaseCoordinator: NSObject, Coordinable, UIViewControllerTransitioningDelegate {
	let type: CoordinatorType
	lazy var authenticationContext = LAContext()
	var navigationController: UINavigationController?

	var rootViewController: UIViewController? {
		nil
	}

	var childCoordinators: [CoordinatorType: Coordinable] = [:]
	var cancellables: Set<AnyCancellable> = []

	func start() {}

	init(type: CoordinatorType) {
		self.type = type
	}
}
