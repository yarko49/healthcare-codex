//
//  Coordinable.swift
//  Allie
//

import UIKit

typealias AllieResultCompletion<ResultType> = (Result<ResultType, Error>) -> Void

enum AllieError: Error {
	case missing(String)
	case invalid(String)
	case compound([Error])
}

protocol Coordinable: AnyObject {
	var type: CoordinatorType { get }
	typealias ActionHandler = () -> Void
	typealias BoolActionHandler = (Bool) -> Void

	var navigationController: UINavigationController? { get }
	var rootViewController: UIViewController? { get }

	var childCoordinators: [CoordinatorType: Coordinable] { get set }
	func addChild(coordinator: Coordinable)
	func removeChild(coordinator: Coordinable) -> Coordinable?
	subscript(type: CoordinatorType) -> Coordinable? { get set }

	func start()

	func showHUD(animated: Bool)
	func hideHUD(animated: Bool)
}

extension Coordinable {
	subscript(type: CoordinatorType) -> Coordinable? {
		get {
			childCoordinators[type]
		} set {
			childCoordinators[type] = newValue
		}
	}

	func addChild(coordinator: Coordinable) {
		childCoordinators[coordinator.type] = coordinator
	}

	@discardableResult
	func removeChild(coordinator: Coordinable) -> Coordinable? {
		childCoordinators.removeValue(forKey: coordinator.type)
	}

	@discardableResult
	func removeCoordinator(ofType type: CoordinatorType) -> Coordinable? {
		childCoordinators.removeValue(forKey: type)
	}

	func showHUD(animated: Bool) {}
	func hideHUD(animated: Bool) {}
}

// MARK: Controller Navigation

extension Coordinable {
	func navigate(to viewController: UIViewController, with presentationStyle: NavigationStyle, animated: Bool = true, resetingStack: Bool = false) {
		switch presentationStyle {
		case .present:
			navigationController?.present(viewController, animated: animated, completion: nil)
		case .push:
			navigationController?.pushViewController(viewController, animated: animated)
		case .pushFullScreen:
			navigationController?.modalPresentationStyle = .fullScreen
			navigationController?.pushViewController(viewController, animated: animated)
		case .resetStack:
			navigationController?.setViewControllers([viewController], animated: animated)
		}
	}
}

enum NavigationStyle: CaseIterable, Hashable {
	case present
	case pushFullScreen
	case push
	case resetStack
}

// MARK: Modal Presentation

extension Coordinable {
	func showAlert(title: String?, detailText: String?, actions: [AlertHelper.AlertAction], fillProportionally: Bool = false) {
		AlertHelper.showAlert(title: title, detailText: detailText, actions: actions, fillProportionally: fillProportionally, from: navigationController)
	}
}
