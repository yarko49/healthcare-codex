import UIKit

class MainAppCoordinator: NSObject, Coordinator {
    
    
    internal var navigationController: UINavigationController?
    internal var childCoordinators: [CoordinatorKey:Coordinator]
    internal weak var parentCoordinator: MasterCoordinator?
    
    var rootViewController: UIViewController? {
        return navigationController
    }
    
    init(with parent: MasterCoordinator?){
        self.navigationController = HomeNC()
        self.parentCoordinator = parent
        self.childCoordinators = [:]
        super.init()
        navigationController?.delegate = self
        start()
    }
    
    internal func start() {
        showHome()
    }
    
    internal func showHome() {
        let homeVC = HomeVC()
        
        let testRequestAction: (()->())? = {
            AlertHelper.showLoader()
            DataContext.shared.testGetHomeNotifications { (notificationList) in
                AlertHelper.hideLoader()
                guard let notificationList = notificationList else { return }
                homeVC.notificationsList = notificationList
                homeVC.notificationsCollectionView.reloadData()
            }
        }
        
        let questionaireAction: (()->())? = { [weak self] in
            self?.goToQuestionaire()
        }
        
        let behavioralNudgeAction: (()->())? = { [weak self] in
            self?.goToCharts()
        }
        
        homeVC.testRequestAction = testRequestAction
        homeVC.questionaireAction = questionaireAction
        homeVC.behavioralNudgeAction = behavioralNudgeAction
        
        self.navigate(to: homeVC, with: .push)
        
    }
    
    //    internal func showFetchedContent(_ content: [String:Any]) {
    //        let alertVC = UIAlertController(title: "RESULT", message: content.description, preferredStyle: .alert)
    //        alertVC.addAction(UIAlertAction(title: "OK BOOMER", style: .default, handler: nil))
    //        navigate(to: alertVC, with: .present)
    //    }
    
    internal func gotoSettings() {
        let settingsCoord = SettingsCoordinator(with: self)
        addChild(coordinator: settingsCoord, with: .settingsCoordinator)
        settingsCoord.start()
    }
    
    internal func goToQuestionaire() {
        let questionaireCoord = QuestionaireCoordinator(with: self)
        addChild(coordinator: questionaireCoord, with: .questionaireCoordinator)
        questionaireCoord.start()
    }
    
    internal func goToCharts() {
        let questionaireCoord = ChartsCoordinator(with: self)
        addChild(coordinator: questionaireCoord, with: .chartsCoordinator)
        questionaireCoord.start()
    }
    
    internal func logout() {
        AlertHelper.showLoader()
        DataContext.shared.logout { [weak self] (success) in
            AlertHelper.hideLoader()
            self?.parentCoordinator?.goToAuth()
        }
    }
    
    deinit {
        navigationController = nil
    }
    
    @objc internal func didTapSettings(){
        self.gotoSettings()
    }
    
    @objc internal func didTapLogout(){
        self.logout()
    }
}

extension MainAppCoordinator: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController is HomeVC {
            if viewController.navigationItem.rightBarButtonItem == nil {
                let logoutBtn = UIBarButtonItem(image: UIImage(named: "gear")?.withRenderingMode(.alwaysTemplate), style: UIBarButtonItem.Style.plain, target: self, action: #selector(didTapLogout))
                logoutBtn.tintColor = UIColor.grey
                viewController.navigationItem.setRightBarButton(logoutBtn, animated: true)
            }
            
            if viewController.navigationItem.leftBarButtonItem == nil {
                let settingsBtn = UIBarButtonItem(image: UIImage(named: "menu")?.withRenderingMode(.alwaysTemplate), style: UIBarButtonItem.Style.plain, target: self, action: #selector(didTapSettings))
                settingsBtn.tintColor = UIColor.grey
                viewController.navigationItem.setLeftBarButton(settingsBtn, animated: true)
            }
        }
    }
    
}

