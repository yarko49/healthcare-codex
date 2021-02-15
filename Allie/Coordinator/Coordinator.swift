import UIKit

protocol Coordinator: AnyObject {
	typealias ActionHandler = () -> Void

	var navigationController: UINavigationController? { get }
	var childCoordinators: [CoordinatorKey: Coordinator] { get set }

	func start()
	func addChild(coordinator: Coordinator, with key: CoordinatorKey)
	func removeChild(coordinator: Coordinator)

	func showHUD(animated: Bool)
	func hideHUD(animated: Bool)
}

extension Coordinator {
	func addChild(coordinator: Coordinator, with key: CoordinatorKey) {
		childCoordinators[key] = coordinator
	}

	func removeChild(coordinator: Coordinator) {
		childCoordinators = childCoordinators.filter {
			$0.value !== coordinator
		}
	}

	func removeChild(_ key: CoordinatorKey) {
		if let coord = childCoordinators[key] {
			removeChild(coordinator: coord)
		}
	}

	func showHUD(animated: Bool) {}
	func hideHUD(animated: Bool) {}
}

// MARK: Controller Navigation

extension Coordinator {
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

extension Coordinator {
	func showAlert(title: String?, detailText: String?, actions: [AlertHelper.AlertAction], fillProportionally: Bool = false) {
		AlertHelper.showAlert(title: title, detailText: detailText, actions: actions, fillProportionally: fillProportionally, from: navigationController)
	}
}
