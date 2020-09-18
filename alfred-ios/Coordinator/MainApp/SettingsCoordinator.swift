import UIKit
import FirebaseAuth

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
        settingsVC.accountDetailsAction = { [weak self] in
            self?.goToAccountDetails()
        }
        settingsVC.myDevicesAction = { [weak self] in
            self?.goToMyDevices()
        }
        settingsVC.notificationsAction = { [weak self] in
            self?.goToNotifications()
        }
        settingsVC.systemAuthorizationAction = { [weak self] in
            self?.goToSystemAuthorization()
        }
        settingsVC.feedbackAction = { [weak self] in
            self?.goToFeedback()
        }
        settingsVC.privacyPolicyAction = { [weak self] in
            self?.goToPrivacyPolicy()
        }
        settingsVC.termsOfServiceAction = { [weak self] in
            self?.goToTermsOfService()
        }
        settingsVC.logoutAction = { [weak self] in
            self?.logout()
        }
        navigate(to: settingsVC, with: .pushFullScreen)
    }
    
    internal func goToAccountDetails() {
        let accountDetailsVC = AccountDetailsVC()
        
        accountDetailsVC.backBtnAction = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        accountDetailsVC.resetPasswordAction = { [weak self] in
            self?.goToPasswordReset()
        }
        
        navigate(to: accountDetailsVC, with: .pushFullScreen)
    }
    
    internal func goToPasswordReset() {
        let accountResetPasswordVC = AccountResetPasswordVC()

        accountResetPasswordVC.backBtnAction = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        //TODO: Functionality is currently missing, we'll get to it when it's available.
        accountResetPasswordVC.sendEmailAction = { [weak accountResetPasswordVC] in
            AlertHelper.showSendLoader()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                AlertHelper.hideLoader()
                accountResetPasswordVC?.showCompletionMessage()
            }
        }
        
        navigate(to: accountResetPasswordVC, with: .pushFullScreen)
        
    }
    
    internal func goToMyDevices() {
        let devicesVC = MyDevicesVC()
        
        devicesVC.backBtnAction = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        navigate(to: devicesVC, with: .pushFullScreen)
    }
    
    internal func goToNotifications() {
        let myNotificationsVC = MyNotificationsVC()
        
        myNotificationsVC.backBtnAction = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        navigate(to: myNotificationsVC, with: .pushFullScreen)
    }
    
    internal func goToSystemAuthorization() {
        //TODO: I think we can only go up to Settings
        if let url = URL.init(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    internal func goToFeedback() {
        
    }
    
    internal func goToPrivacyPolicy() {
        let privacyPolicyVC = PrivacyPolicyVC()
        
        privacyPolicyVC.backBtnAction = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        navigate(to: privacyPolicyVC, with: .pushFullScreen)
    }
    
    internal func goToTermsOfService() {
        let termsOfServiceVC = TermsOfServiceVC()
        
        termsOfServiceVC.backBtnAction = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        navigate(to: termsOfServiceVC, with: .pushFullScreen)
    }
    
    private func logout() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            parentCoordinator?.logout()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    internal func stop() {
        rootViewController?.dismiss(animated: true, completion: { [weak self] in
            guard let self = self else { return }
            self.parentCoordinator?.removeChild(.settingsCoordinator)
        })
    }
    
    deinit {
        navigationController?.viewControllers = []
        rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc internal func backAction(){
        self.stop()
    }
}

extension SettingsCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController is SettingsVC {
            if viewController.navigationItem.leftBarButtonItem == nil {
                let backBtn = UIBarButtonItem(image: UIImage(named: "back")?.withRenderingMode(.alwaysTemplate), style: UIBarButtonItem.Style.plain, target: self, action: #selector(backAction))
                backBtn.tintColor = .black
                viewController.navigationItem.setLeftBarButton(backBtn, animated: true)
            }
        }
    }
}

extension SettingsCoordinator: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        print("dismiss")
        stop()
    }
}
