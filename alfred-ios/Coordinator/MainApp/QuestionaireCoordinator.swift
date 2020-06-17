//
//  QuestionaireCoordinator.swift
//  alfred-ios
//

import Foundation
import UIKit

class QuestionaireCoordinator: NSObject, Coordinator {
    
    
    internal var navigationController: UINavigationController?
    internal var childCoordinators: [CoordinatorKey:Coordinator]
    internal weak var parentCoordinator: MainAppCoordinator?
    
    var rootViewController: UIViewController? {
        return navigationController
    }
    
    init(with parent: MainAppCoordinator?){
        self.navigationController = QuestionaireNC()
        self.parentCoordinator = parent
        self.childCoordinators = [:]
        super.init()
        navigationController?.delegate = self
    }
    
    internal func start() {
        goToQuestionaire()
        if let nav = rootViewController {
            nav.presentationController?.delegate = self
            parentCoordinator?.navigate(to: nav, with: .present)
        }
    }
    
    internal func goToQuestionaire() {
        let questionaireVC = QuestionaireVC()
        questionaireVC.closeAction = { [weak self] in
            self?.stop()
        }
        questionaireVC.startQuestionaireAction = { [weak self] in
            self?.startQuestionaire(with: 0)
        }
        navigate(to: questionaireVC, with: .push)
    }
    
    internal func startQuestionaire(with question: Int) {
        let questionVC = QuestionVC()
        
        navigate(to: questionVC, with: .pushFullScreen)
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

extension QuestionaireCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
    }
    
}

extension QuestionaireCoordinator: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        print("dismiss")

        stop()
    }
}
