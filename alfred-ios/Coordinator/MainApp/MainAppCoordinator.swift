import UIKit
import HealthKit
import HealthKitToFhir
import FHIR

class MainAppCoordinator: NSObject, Coordinator, UIViewControllerTransitioningDelegate {
    
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
                homeVC.setupCards(with: notificationList)
            }
        }
        
        let questionnaireAction: (()->())? = { [weak self] in
            self?.goToQuestionnaire()
        }
        
        homeVC.testRequestAction = testRequestAction
        homeVC.questionnaireAction = questionnaireAction
        self.navigate(to: homeVC, with: .push)
    }
    
    internal func gotoSettings() {
        let settingsCoord = SettingsCoordinator(with: self)
        addChild(coordinator: settingsCoord, with: .settingsCoordinator)
        settingsCoord.start()
    }
    
    internal func goToQuestionnaire() {
        let questionnaireCoord = QuestionnaireCoordinator(with: self)
        addChild(coordinator: questionnaireCoord, with: .questionnaireCoordinator)
        questionnaireCoord.start()
    }

    internal func goToProfile() {
        let profileVC = ProfileVC()
        
        profileVC.refreshHKDataAction = { [weak profileVC] startDate, endDate in
            // TODO: Get only data that user gave authorization for
            let group = DispatchGroup()
            DataContext.shared.userAuthorizedQuantities.forEach { (healthKitQuantityType) in
                if healthKitQuantityType == .bloodPressure {
                    
                    
                } else {
                    group.enter()
                    HealthKitManager.shared.getAverageHighLowValues(for: healthKitQuantityType.getHKitQuantityType(), from: startDate, to: endDate) { (avg, max, min) in
                        profileVC?.currentHKData[healthKitQuantityType] = PatientTrendCellData(averageValue: avg, highValue: max, lowValue: min)
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: .main) { [weak profileVC] in
                profileVC?.patientTrendsTV.reloadData()
            }
        }
        
        profileVC.backBtnAction = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        navigate(to: profileVC, with: .push)
    }
    
    internal func logout() {
        self.parentCoordinator?.goToAuth()
    }
    
    deinit {
        navigationController?.viewControllers = []
        rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc internal func didTapSettings(){
        self.gotoSettings()
    }
    
    @objc internal func didTapProfileBtn(){
        self.goToProfile()
    }
    
    @objc internal func backAction(){
        self.navigationController?.popViewController(animated: true)
    }
    
}
extension MainAppCoordinator: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController is HomeVC {
            if viewController.navigationItem.leftBarButtonItem == nil {
                let profileBtn = UIBarButtonItem(image: UIImage(named: "iconProfile")?.withRenderingMode(.alwaysTemplate), style: UIBarButtonItem.Style.plain, target: self, action: #selector(didTapProfileBtn))
                profileBtn.tintColor = UIColor.black
                viewController.navigationItem.setLeftBarButton(profileBtn, animated: true)
            }
            
        } else if viewController is ProfileVC {
            
            if viewController.navigationItem.rightBarButtonItem == nil {
                let settingsBtn = UIBarButtonItem(image: UIImage(named: "gear")?.withRenderingMode(.alwaysTemplate), style: UIBarButtonItem.Style.plain, target: self, action: #selector(didTapSettings))
                settingsBtn.tintColor = .black
                viewController.navigationItem.setRightBarButton(settingsBtn, animated: true)
            }
            
            if viewController.navigationItem.leftBarButtonItem == nil {
                let backBtn = UIBarButtonItem(image: UIImage(named: "back")?.withRenderingMode(.alwaysTemplate), style: UIBarButtonItem.Style.plain, target: self, action: #selector(backAction))
                backBtn.tintColor = .black
                viewController.navigationItem.setLeftBarButton(backBtn, animated: true)
            }
            
        }
    }
    
}
