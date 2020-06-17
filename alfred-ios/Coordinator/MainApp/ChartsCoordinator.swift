//
//  ChartsCoordinator.swift
//  alfred-ios
//

import Foundation
import UIKit

class ChartsCoordinator: NSObject, Coordinator {
    
    
    internal var navigationController: UINavigationController?
    internal var childCoordinators: [CoordinatorKey:Coordinator]
    internal weak var parentCoordinator: MainAppCoordinator?
    
    var rootViewController: UIViewController? {
        return navigationController
    }
    
    init(with parent: MainAppCoordinator?){
        self.navigationController = ChartsNC() //used to be ChartsNC
        self.parentCoordinator = parent
        self.childCoordinators = [:]
        super.init()
        navigationController?.delegate = self
    }
    
    internal func start() {
        goToCharts()
        if let nav = rootViewController {
            nav.presentationController?.delegate = self
            parentCoordinator?.navigate(to: nav, with: .present)
        }
    }
    
    internal func goToCharts() {
        let chartsVC = Charts()
        chartsVC.closeAction = { [weak self] in
            self?.stop()
        }
        navigate(to: chartsVC, with: .pushFullScreen)
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

extension ChartsCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
    }
    
}

extension ChartsCoordinator: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        print("dismiss")

        stop()
    }
}
