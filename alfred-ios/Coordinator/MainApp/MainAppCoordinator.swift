import UIKit
import HealthKit

class MainAppCoordinator: NSObject, Coordinator, UIViewControllerTransitioningDelegate {
    
    internal var navigationController: UINavigationController?
    internal var childCoordinators: [CoordinatorKey:Coordinator]
    internal weak var parentCoordinator: MasterCoordinator?
  
    var rootViewController: UIViewController? {
        return navigationController
    }
    
    var observation: Resource?
    var bundle: BundleModel?

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
        
        let getCardsAction: (()->())? = {
            AlertHelper.showLoader()
            DataContext.shared.getNotifications { (notificationList) in
                AlertHelper.hideLoader()
                homeVC.setupCards(with: notificationList)
            }
            DispatchQueue.main.async {
                homeVC.refreshControl.endRefreshing()
            }
        }
        
        let questionnaireAction: (()->())? = { [weak self] in
            self?.goToQuestionnaire()
        }
        
        let measurementCellAction: ((InputType)->())? = { [weak self] (inputType) in
            self?.goToInput(with: inputType)
        }
        
        let troubleshootingAction: ((String?, String?, String?, IconType?)->())? = { [weak self] (previewTitle, title, text, icon) in
            self?.goToTroubleshooting(previewTitle: previewTitle, title: title, text: text, icon: icon)
        }
        
        homeVC.getCardsAction = getCardsAction
        homeVC.questionnaireAction = questionnaireAction
        homeVC.measurementCellAction = measurementCellAction
        homeVC.troubleshootingAction = troubleshootingAction
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
    
    internal func goToTroubleshooting(previewTitle: String?, title: String?, text: String?, icon: IconType?) {
        let troubleshootingVC = TroubleshootingVC()
        
        troubleshootingVC.titleText = title ?? ""
        troubleshootingVC.previewTitle = previewTitle ?? ""
        troubleshootingVC.text = text ?? ""
        
        navigate(to:troubleshootingVC, with: .push)
    }
    
    internal func goToInput(with type: InputType) {
        let todayInputVC = TodayInputVC()
        todayInputVC.inputType = type
        let inputAction: ((Resource?, BundleModel?)->())? = { [weak self] (observation, bundle) in
            self?.observation = observation
            self?.bundle = bundle
        }
        todayInputVC.inputAction = inputAction
        navigate(to: todayInputVC, with: .push)
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
    
    @objc internal func addAction(){
        if let observation = observation {
            AlertHelper.showLoader()
            DataContext.shared.postObservation(observation: observation) { (response) in
                AlertHelper.hideLoader()
                if let _ = response {
                    self.observation = nil
                    self.showHome()
                }
            }
        } else if let bundle = bundle {
            AlertHelper.showLoader()
            DataContext.shared.postBundle(bundle: bundle) { (response) in
                AlertHelper.hideLoader()
                if let _ = response {
                    self.bundle = nil
                    self.showHome()
                }
            }
        }
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
            
        } else if viewController is ProfileVC || viewController is TroubleshootingVC || viewController is TodayInputVC {
            
            if viewController is ProfileVC && viewController.navigationItem.rightBarButtonItem == nil {
                let settingsBtn = UIBarButtonItem(image: UIImage(named: "gear")?.withRenderingMode(.alwaysTemplate), style: UIBarButtonItem.Style.plain, target: self, action: #selector(didTapSettings))
                settingsBtn.tintColor = .black
                viewController.navigationItem.setRightBarButton(settingsBtn, animated: true)
            } else if viewController is TodayInputVC && viewController.navigationItem.rightBarButtonItem == nil {
                let addBtn = UIBarButtonItem(title: Str.add, style:UIBarButtonItem.Style.plain, target: self, action: #selector(addAction))
                addBtn.tintColor = UIColor.cursorOrange
                viewController.navigationItem.setRightBarButton(addBtn, animated: true)
            }
            
            if viewController.navigationItem.leftBarButtonItem == nil {
                let backBtn = UIBarButtonItem(image: UIImage(named: "back")?.withRenderingMode(.alwaysTemplate), style: UIBarButtonItem.Style.plain, target: self, action: #selector(backAction))
                backBtn.tintColor = .black
                viewController.navigationItem.setLeftBarButton(backBtn, animated: true)
            }
            
        }
    }
    
}
