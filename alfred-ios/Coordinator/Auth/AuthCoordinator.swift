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
    var emailrequest: String?
    var bundleIdentifier: String?
    var healthDataSuccessfullyUploaded = true
    var chunkSize = 4500
    
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
        self.showOnboarding()
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
    
    internal func goToEmailSignIn(){
        let emailSignInVC = EmailSignInVC()
        
        emailSignInVC.resetPasswordAction = { [weak self] in
            self?.goToReset()
        }
        emailSignInVC.backBtnAction = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        emailSignInVC.alertAction = { [weak self] (title, detail, tv) in
            let okAction = AlertHelper.AlertAction(withTitle: Str.ok) {
                tv.focus()
            }
            self?.showAlert(title: title, detailText: detail, actions: [okAction], fillProportionally: false)
        }
        
        emailSignInVC.signInWithEP = {[weak self] (email, password) in
            self?.goToSignInWithEmail(email : email, password : password)
        }
        navigate(to: emailSignInVC , with: .push)
    }
    
    internal func goToSignInWithEmail(email : String, password: String) {
        AlertHelper.showLoader()
        emailrequest = email
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            self?.getFirebaseToken(authResult: authResult, error: error) {[weak self] in
                self?.checkIfUserExists(authResult: authResult)
            }
        }
    }
    
    internal func goToReset() {
        let resetVC = ResetVC()
        resetVC.backBtnAction = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        resetVC.nextAction = {[weak self] (email) in
            self?.resetPassword(email:email)
        }
        navigate(to: resetVC , with: .push)
    }
    
    internal func resetPassword(email:String?){
        AlertHelper.showSendLoader()
        Auth.auth().sendPasswordReset(withEmail: email ?? "") { error in
            if error != nil {
                AlertHelper.showAlert(title: Str.error, detailText: Str.invalidEmail, actions: [AlertHelper.AlertAction.init(withTitle: Str.ok)])
            } else {
                AlertHelper.hideLoader()
                self.goToResetMessage()
            }
        }
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
    
    internal func getPatientInfo() {
        AlertHelper.showLoader()
        DataContext.shared.postPatientSearch {[weak self] (response) in
            if let response = response, let entries = response.entry, let id = entries[0].resource?.id, let name = entries[0].resource?.name , let email = self?.emailrequest, let dob = entries[0].resource?.birthDate, let gender = entries[0].resource?.gender {
                DataContext.shared.userModel = UserModel(userID: id, email: email, name: name, dob: dob, gender: Gender(rawValue: gender))
                self?.getProfile()
            } else {
                AlertHelper.hideLoader()
                self?.goToMyProfileFirstVC(from: .signIn)
            }
        }
    }
    
    internal func getProfile() {
        DataContext.shared.getProfile {[weak self] (profile) in
            AlertHelper.hideLoader()
            if let profile = profile, let healthMeasurements = profile.healthMeasurements {
                if let weight = healthMeasurements.weight {
                    DataContext.shared.hasSmartScale = weight.available ?? false
                    DataContext.shared.weightInPushNotificationsIsOn = weight.notificationsEnabled ?? false
                }
                if let bloodPressure = healthMeasurements.bloodPressure {
                    DataContext.shared.hasSmartBlockPressureCuff = (bloodPressure.available ?? false)
                    DataContext.shared.bloodPressurePushNotificationsIsOn = bloodPressure.notificationsEnabled ?? false
                }
                
                if let heartRate = healthMeasurements.heartRate, let restingHeartRate = healthMeasurements.restingHeartRate , let steps = healthMeasurements.steps{
                    DataContext.shared.hasSmartWatch = (heartRate.available ?? false) || (restingHeartRate.available ?? false) || (steps.available ?? false )
                    DataContext.shared.hasSmartPedometer = steps.available ?? false
                    DataContext.shared.activityPushNotificationsIsOn = steps.notificationsEnabled ?? false
                    DataContext.shared.surveyPushNotificationsIsOn = (heartRate.notificationsEnabled ?? false) || (restingHeartRate.notificationsEnabled ?? false)
                }
            
                
                DataContext.shared.signUpCompleted = profile.signUpCompleted ?? false
                
                if DataContext.shared.signUpCompleted {
                    self?.goToHealthKitAuthorization()
                } else {
                    self?.goToMyProfileFirstVC(from: .signIn)
                }
            } else {
                self?.goToMyProfileFirstVC(from: .signIn)
            }
        }
    }
    
    internal func goToHealthKitAuthorization() {
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
                self.goToMainApp()
            }
        }
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
        
        signupVC.alertAction = { [weak self] (title, detail, tv) in
            let okAction = AlertHelper.AlertAction(withTitle: Str.ok) {
                tv.focus()
            }
            self?.showAlert(title: title, detailText: detail, actions: [okAction], fillProportionally: false)
        }
        
        signupVC.signUpWithEP = { [weak self](email, password) in
            self?.goToSignUpWithEP(email: email, password: password)
        }
        
        navigate(to: signupVC, with: .push)
    }
    
    
    internal func goToSignUpWithEP(email : String, password : String) {
        AlertHelper.showLoader()
        Auth.auth().createUser(withEmail: email, password: password) {[weak self] authResult, error in
            if let error = error {
                print(error)
                AlertHelper.showAlert(title: Str.error, detailText: Str.signUpFailed, actions: [AlertHelper.AlertAction(withTitle: Str.ok)])
            } else {
                print("Created user")
                self?.getFirebaseToken(authResult: authResult, error: error) {[weak self] in
                    self?.goToMyProfileFirstVC()
                }
            }
        }
    }
    
    
    internal func goToMyProfileFirstVC(from screen: ComingFrom = .signUp){
        let myProfileFirstVC = MyProfileFirstVC()
        myProfileFirstVC.comingFrom = screen
        
        myProfileFirstVC.backBtnAction = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        let sendDataAction: ((String, String, [String])->())? = {[weak self](gender, family, given) in
            self?.goToMyProfileSecondVC(gender: gender, family: family, given: given)
        }
        
        myProfileFirstVC.alertAction = { [weak self] (tv) in
            let okAction = AlertHelper.AlertAction(withTitle: Str.ok) {
                tv?.focus()
            }
            self?.showAlert(title: Str.invalidText, detailText: Str.invalidTextMsg, actions: [okAction])
        }
        
        myProfileFirstVC.sendDataAction = sendDataAction
        navigate(to: myProfileFirstVC, with: .push)
    }
    
    
    
    internal func goToMyProfileSecondVC(gender : String, family: String, given: [String]){
        
        let myProfileSecondVC = MyProfileSecondVC()
        myProfileSecondVC.backBtnAction = {[weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        myProfileSecondVC.patientRequestAction = {[weak self](resourceType, birthdate, weight, height, date) in
            let name = Name(use: "official", family: family, given: given)
            let joinedNames = given.joined(separator: " ")
            DataContext.shared.firstName = joinedNames
            DataContext.shared.patient = Resource(code: nil, effectiveDateTime: nil, id: nil, identifier: nil, meta: nil, resourceType: resourceType, status: nil, subject: nil, valueQuantity: nil, birthDate: birthdate, gender: gender, name: [name], component: nil)
            let patient = DataContext.shared.patient
            self?.goToAppleHealthVCFromProfile(patient: patient ?? Resource(code: nil, effectiveDateTime: "", id: "", identifier: nil, meta: nil, resourceType: "", status: "", subject: nil, valueQuantity: nil, birthDate: "", gender: "", name: nil, component: nil), weight: weight, height: height, date: date)
        }
        
        myProfileSecondVC.alertAction = { [weak self] (tv) in
            let okAction = AlertHelper.AlertAction(withTitle: Str.ok) {
                
            }
            self?.showAlert(title: Str.invalidInput, detailText: Str.emptyPickerField , actions: [okAction])
            
        }
        navigate(to: myProfileSecondVC, with: .push)
    }
    
    
    internal func goToAppleHealthVCFromProfile(patient: Resource, weight: Int, height: Int, date: String){
        
        let appleHealthVC = AppleHealthVC()
        appleHealthVC.comingFrom = .myProfile
        
        appleHealthVC.backBtnAction  = {[weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        appleHealthVC.nextBtnAction = { [weak self] in
            self?.goToMyDevices(patient: patient , weight: weight , height:height , date: date)
        }
        
        navigate(to: appleHealthVC, with: .pushFullScreen)
    }
    
    internal func goToAppleHealthVCFromDevices(){
        
        let appleHealthVC = AppleHealthVC()
        appleHealthVC.comingFrom = .myDevices
        
        appleHealthVC.notNowAction = {[weak self] in
            self?.goToMainApp()
        }
        
        appleHealthVC.activateAction = {[weak self] in
            self?.authorizeHKForUpload()
        }
        
        navigate(to: appleHealthVC, with: .pushFullScreen)
    }
    
    internal func authorizeHKForUpload() {
        HealthKitManager.shared.authorizeHealthKit {[weak self] (authorized, error) in
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
                self?.setChunkSize()
            }
        }
    }
    
    internal func setChunkSize() {
        let changeChunkSizeVC = SelectChunkSizeVC()
        let continueAction: ((Int)->())? = { [weak self] (chunkSize) in
            self?.chunkSize = chunkSize
            self?.startInitialUpload()
        }
        changeChunkSizeVC.continueAction = continueAction
        navigate(to: changeChunkSizeVC, with: .push)
    }
    
    internal func startInitialUpload() {
        let hkDataUploadVC = HKDataUploadVC()
        hkDataUploadVC.queryAction = { [weak self] in
            HealthKitManager.shared.searchHKData { [weak self, weak hkDataUploadVC] (importSuccess) in
                if importSuccess {
                    hkDataUploadVC?.maxProgress = HealthKitManager.shared.numberOfData
                    self?.uploadHKData(for: hkDataUploadVC, completion: { [weak self] (uploadSuccess) in
                        self?.goToAppleHealthVCFromActivate()
                    })
                } else {
                    let okAction = AlertHelper.AlertAction(withTitle: Str.ok) {[weak self] in
                        self?.goToAppleHealthVCFromActivate()
                    }
                    AlertHelper.showAlert(title: Str.error, detailText: Str.importHealthDataFailed, actions: [okAction])
                }
            }
        }
        navigate(to: hkDataUploadVC, with: .push)
    }
    
    func uploadHKData(for hkDataUploadVC: HKDataUploadVC?, completion: @escaping (Bool)-> Void) {
        let chunkedEntries = HealthKitManager.shared.returnAllEntries().chunked(into: chunkSize)
        let chunkGroup = DispatchGroup()
        let entriesToUploadCount = HealthKitManager.shared.returnAllEntries().count
        hkDataUploadVC?.maxProgress = entriesToUploadCount
        var uploaded = 0
        chunkedEntries.enumerated().forEach { (index, element) in
            let timeOffset: TimeInterval = Double(index) * 1.5
            chunkGroup.enter()
            DispatchQueue.main.asyncAfter(deadline: .now() + timeOffset) { [weak self] in
                self?.postBundleRequest(for: element) { (success) in
                    uploaded += success ? element.count : 0
                    hkDataUploadVC?.progress = uploaded
                    chunkGroup.leave()
                }
            }
        }
        chunkGroup.notify(queue:.main) {
            if uploaded < entriesToUploadCount {
                let okAction = AlertHelper.AlertAction(withTitle: Str.ok)
                AlertHelper.showAlert(title: Str.error, detailText: Str.uploadHealthDataFailed, actions: [okAction])
            }
            completion(true)
        }
    }
    
    private func postBundleRequest(for entries: [Entry], completion: @escaping (Bool)->()) {
        let bundle = BundleModel(entry: entries, link: nil, resourceType: "Bundle", total: nil, type: "transaction")
        DataContext.shared.postBundle(bundle: bundle) { (resp) in
            completion(resp != nil)
        }
    }
    
    internal func goToAppleHealthVCFromActivate(){
        
        let appleHealthVC = AppleHealthVC()
        appleHealthVC.comingFrom = .activate
        
        appleHealthVC.nextBtnAction = { [weak self] in
            self?.goToMainApp()
        }
        
        navigate(to: appleHealthVC, with: .pushFullScreen)
    }
    
    internal func goToMyDevices(patient: Resource, weight: Int, height: Int, date: String) {
        let devicesVC = MyDevicesVC()
        
        devicesVC.backBtnAction = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        devicesVC.profileRequestAction = {[weak self] in
            self?.patientAPI(patient: patient, weight: weight , height: height, date: date)
            
        }
        navigate(to: devicesVC, with: .pushFullScreen)
    }
    
    internal func patientAPI(patient: Resource, weight: Int, height: Int, date: String){
        AlertHelper.showLoader()
        guard DataContext.shared.userModel == nil else {
            getHeightWeight(weight: weight,height: height ,date: date)
            return
        }
        DataContext.shared.postPatient(patient: patient) {[weak self] (patientResponse) in
            AlertHelper.hideLoader()
            DataContext.shared.patient = patient
            
            if let _ = patientResponse {
                print("OK STATUS FOR PATIENT : 200")
                let defaultName = Name(use: "", family: "", given: [""])
                DataContext.shared.userModel = UserModel(userID: patientResponse?.id ?? "", email: self?.emailrequest ?? "", name: patientResponse?.name ?? [defaultName], dob: patient.birthDate, gender: Gender(rawValue: DataContext.shared.patient?.gender ?? ""))
                self?.getHeightWeight(weight: weight,height: height ,date: date)
            } else {
                print("request failed")
                AlertHelper.showAlert(title: Str.error, detailText: Str.createPatientFailed, actions: [AlertHelper.AlertAction(withTitle: Str.ok)])
                return
            }
        }
    }
    
    
    internal func getHeightWeight(weight: Int, height: Int, date: String){
        
       
        let weightObservation = Resource(code: DataContext.shared.weightCode, effectiveDateTime: date, id: nil, identifier: nil , meta: nil, resourceType: "Observation", status: "final", subject: Subject(reference: DataContext.shared.getPatientID(), type: "Patient", identifier: nil, display: DataContext.shared.getDisplayName()), valueQuantity: ValueQuantity(value: weight, unit: Str.weightUnit), birthDate: nil, gender: nil, name: nil, component: nil)

        let weightEntry = Entry(fullURL: nil, resource: weightObservation, request: Request(method: "POST", url: "Observation"), search: nil, response: nil)
        
       let heightObservation = Resource(code: DataContext.shared.heightCode, effectiveDateTime: date, id: nil, identifier: nil , meta: nil, resourceType: "Observation", status: "final", subject: Subject(reference: DataContext.shared.getPatientID(), type: "Patient", identifier: nil, display: DataContext.shared.getDisplayName()), valueQuantity: ValueQuantity(value: height, unit: Str.heightUnit), birthDate: nil, gender: nil, name: nil, component: nil)
        
        let heightEntry = Entry(fullURL: nil, resource: heightObservation, request: Request(method: "POST", url: "Observation"), search: nil, response: nil)
        
        let bundle = BundleModel(entry: [weightEntry, heightEntry], link: nil, resourceType: "Bundle", total: nil, type: "transaction")
        
        bundleAction(bundle: bundle)
    }
    
    
    internal func bundleAction(bundle: BundleModel){
        AlertHelper.showLoader()
        DataContext.shared.postBundle(bundle: bundle) { (response) in
            AlertHelper.hideLoader()
            if let response = response {
                print(response)
                DataContext.shared.signUpCompleted = true
                let profile = DataContext.shared.createProfileModel()
                self.profileRequest(profile: profile)
                
            } else {
                print("request failed")
                AlertHelper.showAlert(title: Str.error, detailText: Str.createBundleFailed, actions: [AlertHelper.AlertAction(withTitle: Str.ok)])
            }
        }
        
    }
    
    internal func profileRequest(profile: ProfileModel) {
        AlertHelper.showLoader()
        DataContext.shared.postProfile(profile: profile) { [weak self] success in
            AlertHelper.hideLoader()
            if success {
                print("OK STATUS FOR PROFILE: 200", DataContext.shared.signUpCompleted)
                self?.goToAppleHealthVCFromDevices()
            } else {
                print("request failed")
                AlertHelper.showAlert(title: Str.error, detailText: Str.createProfileFailed, actions: [AlertHelper.AlertAction(withTitle: Str.ok)])
            }
        }
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
            AlertHelper.showAlert(title: Str.error, detailText: Str.signInFailed, actions: [AlertHelper.AlertAction(withTitle: Str.ok)])
        } else if let authResult = authResult {
            authResult.user.getIDToken(completion: { (firebaseToken, error) in
                if let error = error {
                    print(error)
                    AlertHelper.showAlert(title: Str.error, detailText: Str.signInFailed, actions: [AlertHelper.AlertAction(withTitle: Str.ok)])
                } else if let firebaseToken = firebaseToken {
                    AlertHelper.hideLoader()
                    self.emailrequest = Auth.auth().currentUser?.email
                    DataContext.shared.authToken = firebaseToken
                    print(firebaseToken)
                    completionHandler()
                }
            })
        }
    }
    
    private func checkIfUserExists(authResult: AuthDataResult?) {
        let newUser = authResult?.additionalUserInfo?.isNewUser
        if newUser == true {
            goToMyProfileFirstVC()
        }
        else {
            getPatientInfo()
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
                self?.checkIfUserExists(authResult: authResult)
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
                    self?.checkIfUserExists(authResult: authResult)
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
