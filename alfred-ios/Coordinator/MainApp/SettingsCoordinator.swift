import UIKit

class SettingsCoordinator: NSObject, Coordinator {
    
    
    internal var navigationController: UINavigationController?
    internal var childCoordinators: [CoordinatorKey:Coordinator]
    internal weak var parentCoordinator: MainAppCoordinator?
    
    var rootViewController: UIViewController? {
        return navigationController
    }
    
    init(with parent: MainAppCoordinator?){
        self.navigationController = SettingsNC()
        self.parentCoordinator = parent
        self.childCoordinators = [:]
        super.init()
        navigationController?.delegate = self
    }
    
    internal func start() {
        goToSettings()
        if let nav = rootViewController {
            nav.presentationController?.delegate = self
            parentCoordinator?.navigate(to: nav, with: .present)
        }
    }
    
    internal func goToSettings() {
        let settingsVC = SettingsVC()
        settingsVC.closeAction = { [weak self] in
            self?.stop()
        }
        navigate(to: settingsVC, with: .push)
    }
    
    internal func stop() {
        rootViewController?.dismiss(animated: true, completion: { [weak self] in
            guard let self = self else { return }
            self.parentCoordinator?.removeChild(coordinator: self)
        })
    }
 
    deinit {
        navigationController = nil
    }
}

extension SettingsCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
    }
    
}

extension SettingsCoordinator: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        print("dismiss")

        stop()
    }
}
