import UIKit

protocol Coordinable: AnyObject {
	typealias ActionHandler = () -> Void

	var navigationController: UINavigationController? { get }
	var childCoordinators: [CoordinatorType: Coordinable] { get set }

	func start()
	func addChild(coordinator: Coordinable, with key: CoordinatorType)
	func removeChild(coordinator: Coordinable)

	func showHUD(animated: Bool)
	func hideHUD(animated: Bool)
}

extension Coordinable {
	func addChild(coordinator: Coordinable, with key: CoordinatorType) {
		childCoordinators[key] = coordinator
	}

	func removeChild(coordinator: Coordinable) {
		childCoordinators = childCoordinators.filter {
			$0.value !== coordinator
		}
	}

	func removeChild(_ key: CoordinatorType) {
		if let coord = childCoordinators[key] {
			removeChild(coordinator: coord)
		}
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
			navigationController?.pushViewController(viewController, animated: true)
		case .pushFullScreen:
			navigationController?.modalPresentationStyle = .fullScreen
			navigationController?.pushViewController(viewController, animated: true)
		case .resetStack:
			navigationController?.viewControllers = [viewController]
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
