import UIKit
import HealthKit
import GoogleSignIn
import FirebaseAuth
import AuthenticationServices
import CryptoKit

class AuthCoordinator: NSObject, Coordinator , UIViewControllerTransitioningDelegate {
    
    internal var navigationController: UINavigationController?
    internal var childCoordinators: [CoordinatorKey:Coordinator]
    internal weak var parentCoordinator: MasterCoordinator?
    
    var currentNonce : String?
    var emailSignIn : EmailSignInVC?
    
    var rootViewController: UIViewController? {
        return navigationController
    }
    
    init(withParent parent: MasterCoordinator?){
        self.navigationController = AuthNC()
        self.parentCoordinator = parent
        self.childCoordinators = [:]
        super.init()
        GIDSignIn.sharedInstance().delegate = self
        
        start()
    }
    
    internal func start() {
        //TODO: We should direct a user that has already signed up, logged in or not, to the respective flow.
        if DataContext.shared.hasCompletedOnboarding {
            self.showOnboarding()
        } else {
            self.showOnboarding()
        }
    }
    
    internal func showOnboarding(){
        
        let onboardingVC = OnboardingVC()
        onboardingVC.signInWithAppleAction = {[weak self] in
            self?.signInWithApple()
        }
        
        onboardingVC.signInWithEmailAction = { [weak self] in
            self?.goToEmailSignIn()
        }
        onboardingVC.signupAction = { [weak self] in
            self?.goToSignup()
        }
        
        self.navigate(to: onboardingVC, with: .push)
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
    
    internal func goToEmailSignIn(){
        let emailSignInVC = EmailSignInVC()
        
        emailSignInVC.resetPasswordAction = { [weak self] in
            self?.goToReset()
        }
        emailSignInVC.backBtnAction = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        emailSignInVC.signInWithEP = {[weak self] (email, password) in
            self?.goToSignInWithEmail(email : email, password : password)
        }
        navigate(to: emailSignInVC , with: .push)
    }
    
    internal func goToSignInWithEmail(email : String, password: String){
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            self?.getFirebaseToken(authResult: authResult, error: error) {[weak self] in
                DispatchQueue.main.async {
                    self?.goToHealthKitAuthorization()
                }
            }
        }
    }
    
    internal func goToReset() {
        
        let resetVC = ResetVC()
        resetVC.backBtnAction = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        resetVC.nextAction = {[weak self] in
            self?.goToResetMessage()
        }
        navigate(to: resetVC , with: .push)
    }
    
    internal func goToResetMessage() {
        
        let resetMessageVC = ResetMessageVC()
        resetMessageVC.backBtnAction = {[weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        resetMessageVC.backToSignInAction = {[weak self] in
            self?.navigationController?.popViewController(animated: false)
            self?.navigationController?.popViewController(animated: true)
        }
        navigate(to: resetMessageVC , with: .push)
    }
    
    
    public func goToMainApp() {
        parentCoordinator?.goToMainApp()
    }
    
    
    public func goToSignup(){
        let signupVC = SignupVC()
        signupVC.backBtnAction = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        signupVC.goToTermsOfService = { [weak self] in
            self?.goToTermsOfService()
        }
        signupVC.goToPrivacyPolicy = { [weak self] in
            self?.goToPrivacyPolicy()
        }
        
        signupVC.signUpWithEP = { [weak self](email, password) in
            self?.goToSignUpWithEP(email: email, password: password)
        }
        navigate(to: signupVC, with: .push)
    }
    
    
    internal func goToSignUpWithEP(email : String, password : String) {
        Auth.auth().createUser(withEmail: email, password: password) {[weak self] authResult, error in
            print("Created user")
            self?.getFirebaseToken(authResult: authResult, error: error) {[weak self] in
                print("redirect to Myprofile")
                self?.goToMyProfileFirstVC()
            }
        }
    }
    
    internal func goToMyProfileFirstVC(){
        
        let myProfileFirstVC = MyProfileFirstVC()
        
        myProfileFirstVC.backBtnAction = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        myProfileFirstVC.nextBtnAction = {[weak self] in
            self?.goToMyProfileSecondVC()
        }
        
        navigate(to: myProfileFirstVC, with: .push)
        
    }
    
    internal func goToMyProfileSecondVC(){
        
        let myProfileSecondVC = MyProfileSecondVC()
        myProfileSecondVC.backBtnAction = {[weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    
        navigate(to: myProfileSecondVC, with: .push)
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
    
    func signInWithApple(){
        if #available(iOS 13.0, *) {
            let request = startSignInWithAppleFlow()
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
            
            print("Got in startSignInWithApple")
            
        } else {
            print("below 13.0 version")
        }
    }
    
    @available(iOS 13, *)
    func startSignInWithAppleFlow() -> ASAuthorizationOpenIDRequest {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let nonce = AppleSecurityManager.randomNonceString()
        request.nonce = AppleSecurityManager.sha256(nonce)
        currentNonce = nonce
        print(nonce)
        return request
    }
    
    private func getFirebaseToken(authResult: AuthDataResult?, error: Error?, completionHandler: @escaping () -> ()) {
        if let error = error {
            print(error)
        } else if let authResult = authResult {
            authResult.user.getIDToken(completion: { (firebaseToken, error) in
                if let error = error {
                    print(error)
                } else if let firebaseToken = firebaseToken {
                    DataContext.shared.authToken = firebaseToken
                    print(firebaseToken)
                    completionHandler()
                }
            })
        }
    }
}

extension AuthCoordinator: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        
        if let error = error {
            print(error)
            return
        }
        
        guard let authentication = user.authentication, error == nil
            else {  print(error as Any)
                return
        }
        
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) {[weak self] (authResult, error) in
            self?.getFirebaseToken(authResult: authResult, error: error) {[weak self] in
                DispatchQueue.main.async {
                    self?.goToHealthKitAuthorization()
                }
            }
        }
    }
}

extension AuthCoordinator: ASAuthorizationControllerDelegate {
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        print("Hello Apple")
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else{
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            Auth.auth().signIn(with: credential)  {[weak self] (authResult, error) in
                self?.getFirebaseToken(authResult: authResult, error: error) {[weak self] in
                    DispatchQueue.main.async {
                        self?.goToHealthKitAuthorization()
                    }
                }
            }
        }
    }
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple errored: \(error)")
    }
    
    
    func signOut(){
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
}


extension AuthCoordinator : ASAuthorizationControllerPresentationContextProviding {
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return navigationController?.visibleViewController?.view.window ?? UIWindow(frame: UIScreen.main.bounds)
    }
}
