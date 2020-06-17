import UIKit

protocol Coordinator: class {
    var navigationController: UINavigationController? { get }
    var childCoordinators: [CoordinatorKey:Coordinator] { get set }
    
    func start()
    func addChild(coordinator: Coordinator, with key: CoordinatorKey)
    func removeChild(coordinator: Coordinator)
}


extension Coordinator {
    func addChild(coordinator: Coordinator, with
        key: CoordinatorKey) {
        
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
}

// MARK: Controller Navigation
extension Coordinator {
    
    func navigate(to viewController: UIViewController, with presentationStyle: navigationStyle, animated: Bool = true, resetingStack: Bool = false) {
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

enum navigationStyle {
    case present
    case pushFullScreen
    case push
    case resetStack
}

// MARK: Modal Presentation

extension Coordinator {
    internal func showAlert(title: String?, detailText: String?, actions: [AlertHelper.AlertAction], fillProportionally: Bool = false ) {
        AlertHelper.showAlert(title: title, detailText: detailText, actions: actions, fillProportionally: fillProportionally, from: self.navigationController)
    }
}
