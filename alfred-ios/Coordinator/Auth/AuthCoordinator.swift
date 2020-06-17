import UIKit
import HealthKit

class AuthCoordinator: Coordinator {
    
    
    internal var navigationController: UINavigationController?
    internal var childCoordinators: [CoordinatorKey:Coordinator]
    internal weak var parentCoordinator: MasterCoordinator?
    
    var rootViewController: UIViewController? {
        return navigationController
    }
    
    init(withParent parent: MasterCoordinator?){
        self.navigationController = AuthNC()
        self.parentCoordinator = parent
        self.childCoordinators = [:]
        start()
    }
    
   
    internal func start() {
        goToHealthKitAuthorization()
    }
    
    internal func goToHealthKitAuthorization() {
        let healthKitAuthorizationVC = HealthKitAuthorizationVC()
        
        healthKitAuthorizationVC.authorizeAction = { [weak self] in
            HealthKitManager.shared.authorizeHealthKit { (authorized, error) in
                
                guard authorized else {
                    
                    let baseMessage = "HealthKit Authorization Failed"
                    
                    if let error = error {
                        print("\(baseMessage). Reason: \(error.localizedDescription)")
                    } else {
                        print(baseMessage)
                    }
                    
                    return
                }
                
                print("HealthKit Successfully Authorized.")
                DispatchQueue.main.async {
                    self?.goToMainApp()
                }
            }
        }
        
        navigate(to: healthKitAuthorizationVC, with: .push, animated: false)
    }

    internal func goToLogin() {
        let loginVC = LoginVC()
        loginVC.loginAction = { [weak self] (email, pass) in
            AlertHelper.showLoader()
            DataContext.shared.login(withEmail: email, andPassword: pass, completion: { (success) in
                AlertHelper.hideLoader()
                if success {
                    self?.goToMainApp()
                }
            })
            
        }
        loginVC.registerAction = { [weak self] in
            self?.goToRegister()
        }
        navigate(to: loginVC, with: .push, animated: false)
    }
    
    internal func goToRegister() {
        let registerVC = RegisterVC()
        registerVC.registerAction = { [weak self] (email, pass, confirmPass) in
            AlertHelper.showLoader()
            DataContext.shared.register(withEmail: email, password: pass, andConfirmPassword: confirmPass, completion: { (success) in
                AlertHelper.hideLoader()
                if success {
                    self?.navigationController?.popViewController(animated: true)
                }
            })
        }
        registerVC.loginAction = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        navigate(to: registerVC, with: .push, animated: false)
    }
    
    public func goToMainApp() {
        parentCoordinator?.goToMainApp()
    }
}

