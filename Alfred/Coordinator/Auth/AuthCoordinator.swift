import AuthenticationServices
import CareKitStore
import CryptoKit
import FirebaseAuth
import GoogleSignIn
import HealthKit
import LocalAuthentication
import UIKit

enum SendEmailPurpose {
	case signIn
	case signUp
}

class AuthCoordinator: NSObject, Coordinator, UIViewControllerTransitioningDelegate {
	internal var navigationController: UINavigationController? = {
		UINavigationController()
	}()

	internal var childCoordinators: [CoordinatorKey: Coordinator]
	internal weak var parentCoordinator: MasterCoordinator?

	var currentNonce: String?
	var emailrequest: String?
	var bundleIdentifier: String?
	var healthDataSuccessfullyUploaded = true
	var chunkSize = 4500

	var rootViewController: UIViewController? {
		navigationController
	}

	init(withParent parent: MasterCoordinator?, deepLink: String = "") {
		self.parentCoordinator = parent
		self.childCoordinators = [:]
		super.init()
		GIDSignIn.sharedInstance().delegate = self

		if deepLink != "" {
			verifySendLink(link: deepLink)
		} else {
			start()
		}
	}

	internal func start() {
		showOnboarding()
	}

	func showHUD(animated: Bool = true) {
		parentCoordinator?.showHUD(animated: animated)
	}

	func hideHUD(animated: Bool = true) {
		parentCoordinator?.hideHUD(animated: animated)
	}

	internal func showOnboarding() {
		let onboardingViewController = OnboardingViewController()
		onboardingViewController.signInWithAppleAction = { [weak self] in
			self?.signInWithApple()
		}

		onboardingViewController.signInWithEmailAction = { [weak self] in
			self?.goToEmailSignIn()
		}
		onboardingViewController.signupAction = { [weak self] in
			self?.goToSignup()
		}
		navigate(to: onboardingViewController, with: .push)
	}

	internal func goToEmailSignIn() {
		let emailSignInViewController = EmailSignInViewController()

		emailSignInViewController.backButtonAction = { [weak self] in
			self?.navigationController?.popViewController(animated: true)
		}

		emailSignInViewController.alertAction = { [weak self] title, detail, tv in
			let okAction = AlertHelper.AlertAction(withTitle: Str.ok) {
				tv.focus()
			}
			self?.showAlert(title: title, detailText: detail, actions: [okAction], fillProportionally: false)
		}

		emailSignInViewController.signInWithEmail = { [weak self] email in
			self?.sendEmailLink(email: email, for: .signIn)
		}
		navigate(to: emailSignInViewController, with: .push)
	}

	internal func sendEmailLink(email: String, for purpose: SendEmailPurpose) {
		guard let bundleId = Bundle.main.bundleIdentifier else { return }
		Auth.auth().tenantID = nil
		let actionCodeSettings = ActionCodeSettings()
		actionCodeSettings.url = URL(string: AppConfig.firebaseDeeplinkURL)
		actionCodeSettings.handleCodeInApp = true
		actionCodeSettings.setIOSBundleID(bundleId)
		Auth.auth().sendSignInLink(toEmail: email, actionCodeSettings: actionCodeSettings) { [weak self] error in
			if let error = error {
				ALog.error("Send signin Link", error: error)
				AlertHelper.showAlert(title: Str.error, detailText: Str.failedSendLink, actions: [AlertHelper.AlertAction(withTitle: Str.ok)])
				return
			}

			DataContext.shared.emailForLink = email
			self?.emailrequest = email
			self?.emailSentSuccess(email: email, from: purpose)
		}
	}

	internal func emailSentSuccess(email: String, from purpose: SendEmailPurpose) {
		let emailSentViewController = EmailSentViewController()
		emailSentViewController.email = email
		emailSentViewController.purpose = purpose

		emailSentViewController.backBtnAction = { [weak self] in
			self?.navigationController?.popViewController(animated: true)
		}
		emailSentViewController.openMailApp = {
			guard let mailURL = URL(string: "message://") else { return }
			if UIApplication.shared.canOpenURL(mailURL) {
				UIApplication.shared.open(mailURL, options: [:], completionHandler: nil)
			}
		}
		emailSentViewController.goToTermsOfService = { [weak self] in
			self?.goToTermsOfService()
		}
		emailSentViewController.goToPrivacyPolicy = { [weak self] in
			self?.goToPrivacyPolicy()
		}
		navigate(to: emailSentViewController, with: .push)
	}

	internal func verifySendLink(link: String) {
		if let email = DataContext.shared.emailForLink {
			goToWelcomeView(email: email, link: link)
		} else {
			start()
		}
	}

	internal func goToWelcomeView(email: String, link: String) {
		let appleHealthViewController = AppleHealthViewController()
		appleHealthViewController.comingFrom = .welcome

		var user: AuthDataResult?

		let signInAction: (() -> Void)? = { [weak self] in
			self?.showHUD()
			if Auth.auth().isSignIn(withEmailLink: link) {
				Auth.auth().tenantID = nil
				Auth.auth().signIn(withEmail: email, link: link) { [weak self] authResult, error in
					appleHealthViewController.comingFrom = .welcomeFailure
					if error == nil {
						self?.getFirebaseAuthTokenResult(authDataResult: authResult, error: error, completion: { [weak self] _ in
							self?.hideHUD()
							user = authResult
							appleHealthViewController.comingFrom = .welcomeSuccess
							appleHealthViewController.setupTexts()
						})
					} else {
						self?.hideHUD()
						appleHealthViewController.setupTexts()
						AlertHelper.showAlert(title: error?.localizedDescription, detailText: Str.signInFailed, actions: [AlertHelper.AlertAction(withTitle: Str.ok)])
					}
				}
			} else {
				self?.hideHUD()
				appleHealthViewController.comingFrom = .welcomeFailure
				appleHealthViewController.setupTexts()
				AlertHelper.showAlert(title: Str.error, detailText: Str.signInFailed, actions: [AlertHelper.AlertAction(withTitle: Str.ok)])
			}
		}

		appleHealthViewController.nextBtnAction = { [weak self] in
			if user != nil {
				self?.checkIfUserExists(user: user)
			} else {
				self?.start()
			}
		}

		appleHealthViewController.signInAction = signInAction
		navigate(to: appleHealthViewController, with: .pushFullScreen)
	}

	internal func goToReset() {
		let resetViewController = ResetViewController()
		resetViewController.backBtnAction = { [weak self] in
			self?.navigationController?.popViewController(animated: true)
		}
		resetViewController.nextAction = { [weak self] email in
			self?.resetPassword(email: email)
		}
		navigate(to: resetViewController, with: .push)
	}

	internal func resetPassword(email: String?) {
		showHUD()
		Auth.auth().sendPasswordReset(withEmail: email ?? "") { [weak self] error in
			self?.hideHUD()
			if error != nil {
				AlertHelper.showAlert(title: Str.error, detailText: Str.invalidEmail, actions: [AlertHelper.AlertAction(withTitle: Str.ok)])
			} else {
				self?.goToResetMessage()
			}
		}
	}

	internal func goToResetMessage() {
		let resetMessageViewController = ResetMessageViewController()
		resetMessageViewController.backBtnAction = { [weak self] in
			self?.navigationController?.popViewController(animated: true)
		}

		resetMessageViewController.backToSignInAction = { [weak self] in
			self?.navigationController?.popViewController(animated: false)
			self?.navigationController?.popViewController(animated: true)
		}
		navigate(to: resetMessageViewController, with: .push)
	}

	internal func getPatientInfo() {
		guard let user = Auth.auth().currentUser else {
			return
		}

		showHUD()
		DataContext.shared.searchPatient(user: user, completion: { [weak self] success in
			self?.hideHUD()
			if success {
				DataContext.shared.identifyCrashlytics()
				self?.getProfile()
			} else {
				self?.goToMyProfileFirstViewController(from: .signIn)
			}
		})
	}

	internal func getProfile() {
		showHUD()
		DataContext.shared.getProfileAPI { [weak self] success in
			self?.hideHUD()
			if success {
				if DataContext.shared.signUpCompleted {
					self?.goToHealthKitAuthorization()
				} else {
					self?.goToMyProfileFirstViewController(from: .signIn)
				}
			} else {
				self?.goToMyProfileFirstViewController(from: .signIn)
			}
		}
	}

	internal func goToHealthKitAuthorization() {
		HealthKitManager.shared.authorizeHealthKit { authorized, error in
			guard authorized else {
				let baseMessage = "HealthKit Authorization Failed"
				if let error = error {
					ALog.error("Send signin Link \(baseMessage)", error: error)
				} else {
					ALog.info("baseMessage \(baseMessage)")
				}
				return
			}
			ALog.info("HealthKit Successfully Authorized.")
			DispatchQueue.main.async {
				self.syncHKData()
			}
		}
	}

	internal func syncHKData() {
		var loadingShouldAppear = true
		let hkDataUploadViewController = HKDataUploadViewController()
		SyncManager.shared.syncData(initialUpload: false, chunkSize: chunkSize) { [weak self] uploaded, total in
			if total > 500, loadingShouldAppear {
				loadingShouldAppear = false
				self?.navigate(to: hkDataUploadViewController, with: .push)
			} else if total > 500 {
				hkDataUploadViewController.progress = uploaded
				hkDataUploadViewController.maxProgress = total
			}
		} completion: { [weak self] success in
			if success {
				self?.goToMainApp()
			} else {
				AlertHelper.showAlert(title: Str.error, detailText: Str.importHealthDataFailed, actions: [])
				self?.goToMainApp()
			}
		}
	}

	public func goToMainApp() {
		parentCoordinator?.goToMainApp()
	}

	public func goToSignup() {
		let signupViewController = SignupViewController()
		signupViewController.backBtnAction = { [weak self] in
			self?.navigationController?.popViewController(animated: true)
		}
		signupViewController.goToTermsOfService = { [weak self] in
			self?.goToTermsOfService()
		}
		signupViewController.goToPrivacyPolicy = { [weak self] in
			self?.goToPrivacyPolicy()
		}

		signupViewController.alertAction = { [weak self] title, detail, tv in
			let okAction = AlertHelper.AlertAction(withTitle: Str.ok) {
				tv.focus()
			}
			self?.showAlert(title: title, detailText: detail, actions: [okAction], fillProportionally: false)
		}

		signupViewController.signUpWithEmail = { [weak self] email in
			self?.sendEmailLink(email: email, for: .signUp)
		}

		navigate(to: signupViewController, with: .push)
	}

	internal func goToMyProfileFirstViewController(from screen: ComingFrom = .signUp) {
		let myProfileFirstViewController = MyProfileFirstViewController()
		myProfileFirstViewController.comingFrom = screen

		myProfileFirstViewController.backBtnAction = { [weak self] in
			self?.navigationController?.popViewController(animated: true)
		}

		let sendDataAction: ((String, String, [String]) -> Void)? = { [weak self] gender, family, given in
			self?.goToMyProfileSecondViewController(gender: gender, family: family, given: given)
		}

		myProfileFirstViewController.alertAction = { [weak self] tv in
			let okAction = AlertHelper.AlertAction(withTitle: Str.ok) {
				tv?.focus()
			}
			self?.showAlert(title: Str.invalidText, detailText: Str.invalidTextMsg, actions: [okAction])
		}

		myProfileFirstViewController.sendDataAction = sendDataAction
		navigate(to: myProfileFirstViewController, with: .push)
	}

	internal func goToMyProfileSecondViewController(gender: String, family: String, given: [String]) {
		let myProfileSecondViewController = MyProfileSecondViewController()
		myProfileSecondViewController.backBtnAction = { [weak self] in
			self?.navigationController?.popViewController(animated: true)
		}

		myProfileSecondViewController.patientRequestAction = { [weak self] resourceType, birthdate, weight, height, date in
			let name = ResourceName(use: "official", family: family, given: given)
			let joinedNames = given.joined(separator: " ")
			DataContext.shared.firstName = joinedNames
			DataContext.shared.resouce = CodexResource(id: nil, code: nil, effectiveDateTime: nil, identifier: nil, meta: nil, resourceType: resourceType, status: nil, subject: nil, valueQuantity: nil, birthDate: birthdate, gender: gender, name: [name], component: nil)
			let patientResource = DataContext.shared.resouce
			self?.goToAppleHealthViewControllerFromProfile(patient: patientResource ?? CodexResource(id: "", code: nil, effectiveDateTime: "", identifier: nil, meta: nil, resourceType: "", status: "", subject: nil, valueQuantity: nil, birthDate: "", gender: "", name: nil, component: nil), weight: weight, height: height, date: date)
		}

		myProfileSecondViewController.alertAction = { [weak self] _ in
			let okAction = AlertHelper.AlertAction(withTitle: Str.ok) {}
			self?.showAlert(title: Str.invalidInput, detailText: Str.emptyPickerField, actions: [okAction])
		}
		navigate(to: myProfileSecondViewController, with: .push)
	}

	internal func goToAppleHealthViewControllerFromProfile(patient: CodexResource, weight: Int, height: Int, date: String) {
		let appleHealthViewController = AppleHealthViewController()
		appleHealthViewController.comingFrom = .myProfile

		appleHealthViewController.backBtnAction = { [weak self] in
			self?.navigationController?.popViewController(animated: true)
		}

		appleHealthViewController.nextBtnAction = { [weak self] in
			self?.goToMyDevices(patient: patient, weight: weight, height: height, date: date)
		}

		navigate(to: appleHealthViewController, with: .pushFullScreen)
	}

	internal func goToAppleHealthViewControllerFromDevices() {
		let appleHealthViewController = AppleHealthViewController()
		appleHealthViewController.comingFrom = .myDevices

		appleHealthViewController.notNowAction = { [weak self] in
			self?.goToMainApp()
		}

		appleHealthViewController.activateAction = { [weak self] in
			self?.authorizeHKForUpload()
		}

		navigate(to: appleHealthViewController, with: .pushFullScreen)
	}

	internal func authorizeHKForUpload() {
		HealthKitManager.shared.authorizeHealthKit { [weak self] authorized, error in
			guard authorized else {
				let baseMessage = "HealthKit Authorization Failed"
				if let error = error {
					ALog.error("BaseMessage \(baseMessage) Reason:", error: error)
				} else {
					ALog.info("Base Message \(baseMessage)")
				}
				return
			}
			ALog.info("HealthKit Successfully Authorized.")
			DispatchQueue.main.async {
				self?.setChunkSize()
			}
		}
	}

	internal func setChunkSize() {
		let changeChunkSizeViewController = SelectChunkSizeViewController()
		let continueAction: ((Int) -> Void)? = { [weak self] chunkSize in
			self?.chunkSize = chunkSize
			self?.startInitialUpload()
		}
		changeChunkSizeViewController.continueAction = continueAction
		navigate(to: changeChunkSizeViewController, with: .push)
	}

	internal func startInitialUpload() {
		let hkDataUploadViewController = HKDataUploadViewController()
		hkDataUploadViewController.queryAction = { [weak self] in
			SyncManager.shared.syncData(chunkSize: self?.chunkSize) { uploaded, total in
				hkDataUploadViewController.progress = uploaded
				hkDataUploadViewController.maxProgress = total
			} completion: { success in
				if success {
					self?.goToAppleHealthViewControllerFromActivate()
				} else {
					let okAction = AlertHelper.AlertAction(withTitle: Str.ok) { [weak self] in
						self?.goToAppleHealthViewControllerFromActivate()
					}
					AlertHelper.showAlert(title: Str.error, detailText: Str.importHealthDataFailed, actions: [okAction])
				}
			}
		}
		navigate(to: hkDataUploadViewController, with: .push)
	}

	internal func goToAppleHealthViewControllerFromActivate() {
		let appleHealthViewController = AppleHealthViewController()
		appleHealthViewController.comingFrom = .activate
		appleHealthViewController.nextBtnAction = { [weak self] in
			self?.goToMainApp()
		}

		navigate(to: appleHealthViewController, with: .pushFullScreen)
	}

	internal func goToMyDevices(patient: CodexResource, weight: Int, height: Int, date: String) {
		let devicesViewController = MyDevicesViewController()

		devicesViewController.backBtnAction = { [weak self] in
			self?.navigationController?.popViewController(animated: true)
		}

		devicesViewController.profileRequestAction = { [weak self] in
			self?.patientAPI(patient: patient, weight: weight, height: height, date: date)
		}
		navigate(to: devicesViewController, with: .pushFullScreen)
	}

	internal func patientAPI(patient: CodexResource, weight: Int, height: Int, date: String) {
		showHUD()
		guard DataContext.shared.userModel == nil else {
			getHeightWeight(weight: weight, height: height, date: date)
			return
		}
		AlfredClient.client.postPatient(patient: patient) { [weak self] result in
			self?.hideHUD()
			DataContext.shared.resouce = patient
			switch result {
			case .success(let resource):
				ALog.info("OK STATUS FOR PATIENT : 200")
				let defaultName = ResourceName(use: "", family: "", given: [""])
				DataContext.shared.userModel = UserModel(userID: resource.id ?? "", email: self?.emailrequest ?? "", name: resource.name ?? [defaultName], dob: patient.birthDate, gender: Gender(rawValue: DataContext.shared.resouce?.gender ?? ""))
				self?.getHeightWeight(weight: weight, height: height, date: date)
			case .failure(let error):
				ALog.error("request falied", error: error)
				AlertHelper.showAlert(title: Str.error, detailText: Str.createPatientFailed, actions: [AlertHelper.AlertAction(withTitle: Str.ok)])
				return
			}
		}
	}

	internal func getHeightWeight(weight: Int, height: Int, date: String) {
		let weightObservation = CodexResource(id: nil, code: DataContext.shared.weightCode, effectiveDateTime: date, identifier: nil, meta: nil, resourceType: "Observation", status: "final", subject: Subject(reference: DataContext.shared.patientID, type: "Patient", identifier: nil, display: DataContext.shared.displayName), valueQuantity: ValueQuantity(value: weight, unit: Str.weightUnit), birthDate: nil, gender: nil, name: nil, component: nil)
		let weightEntry = BundleEntry(fullURL: nil, resource: weightObservation, request: BundleRequest(method: "POST", url: "Observation"), search: nil, response: nil)
		let heightObservation = CodexResource(id: nil, code: DataContext.shared.heightCode, effectiveDateTime: date, identifier: nil, meta: nil, resourceType: "Observation", status: "final", subject: Subject(reference: DataContext.shared.patientID, type: "Patient", identifier: nil, display: DataContext.shared.displayName), valueQuantity: ValueQuantity(value: height, unit: Str.heightUnit), birthDate: nil, gender: nil, name: nil, component: nil)
		let heightEntry = BundleEntry(fullURL: nil, resource: heightObservation, request: BundleRequest(method: "POST", url: "Observation"), search: nil, response: nil)
		let bundle = CodexBundle(entry: [weightEntry, heightEntry], link: nil, resourceType: "Bundle", total: nil, type: "transaction")
		bundleAction(bundle: bundle)
	}

	internal func bundleAction(bundle: CodexBundle) {
		showHUD()
		AlfredClient.client.postBundle(bundle: bundle) { [weak self] result in
			self?.hideHUD()
			switch result {
			case .success(let response):
				ALog.info("response \(String(describing: response))")
				DataContext.shared.signUpCompleted = true
				let profile = DataContext.shared.createProfile()
				self?.profileRequest(profile: profile)
			case .failure(let error):
				ALog.error("request failed =", error: error)
				AlertHelper.showAlert(title: Str.error, detailText: Str.createBundleFailed, actions: [AlertHelper.AlertAction(withTitle: Str.ok)])
			}
		}
	}

	internal func profileRequest(profile: Profile) {
		showHUD()
		AlfredClient.client.postProfile(profile: profile) { [weak self] result in
			self?.hideHUD()
			switch result {
			case .success(let finished):
				DataContext.shared.identifyCrashlytics()
				ALog.info("OK STATUS FOR PROFILE: 200 \(String(describing: DataContext.shared.signUpCompleted)), \(finished)")
				self?.goToAppleHealthViewControllerFromDevices()
			case .failure(let error):
				ALog.error("request failed", error: error)
				AlertHelper.showAlert(title: Str.error, detailText: Str.createProfileFailed, actions: [AlertHelper.AlertAction(withTitle: Str.ok)])
			}
		}
	}

	internal func goToPrivacyPolicy() {
		let privacyPolicyViewController = PrivacyPolicyViewController()

		privacyPolicyViewController.backBtnAction = { [weak self] in
			self?.navigationController?.popViewController(animated: true)
		}
		navigate(to: privacyPolicyViewController, with: .pushFullScreen)
	}

	internal func goToTermsOfService() {
		let termsOfServiceViewController = TermsOfServiceViewController()

		termsOfServiceViewController.backBtnAction = { [weak self] in
			self?.navigationController?.popViewController(animated: true)
		}
		navigate(to: termsOfServiceViewController, with: .pushFullScreen)
	}

	func signInWithApple() {
		let request = startSignInWithAppleFlow()
		let authorizationController = ASAuthorizationController(authorizationRequests: [request])
		authorizationController.delegate = self
		authorizationController.presentationContextProvider = self
		authorizationController.performRequests()
		ALog.info("Got in startSignInWithApple")
	}

	func startSignInWithAppleFlow() -> ASAuthorizationOpenIDRequest {
		let appleIDProvider = ASAuthorizationAppleIDProvider()
		let request = appleIDProvider.createRequest()
		request.requestedScopes = [.fullName, .email]
		let nonce = AppleSecurityManager.randomNonceString()
		request.nonce = AppleSecurityManager.sha256(nonce)
		currentNonce = nonce
		ALog.info("nonce: \(nonce)")
		return request
	}

	private func getFirebaseAuthTokenResult(authDataResult: AuthDataResult?, error: Error?, completion: @escaping (Bool) -> Void) {
		if let error = error {
			ALog.error(error: error)
			hideHUD()
			AlertHelper.showAlert(title: Str.error, detailText: Str.signInFailed, actions: [AlertHelper.AlertAction(withTitle: Str.ok)])
		} else if let authDataResult = authDataResult {
			authDataResult.user.getIDTokenResult { [weak self] authTokenResult, _ in
				self?.hideHUD()
				if let error = error {
					ALog.info("\(error.localizedDescription)")
					AlertHelper.showAlert(title: Str.error, detailText: Str.signInFailed, actions: [AlertHelper.AlertAction(withTitle: Str.ok)])
					completion(false)
				} else if let authTokenResult = authTokenResult {
					self?.emailrequest = Auth.auth().currentUser?.email
					DataContext.shared.authToken = authTokenResult.token
					ALog.info("firebaseToken: \(authTokenResult.token)")
					completion(true)
				}
			}
		}
	}

	private func checkIfUserExists(user: AuthDataResult?) {
		let newUser = user?.additionalUserInfo?.isNewUser
		if newUser == true {
			goToMyProfileFirstViewController()
		} else {
			getPatientInfo()
		}
	}
}

extension AuthCoordinator: GIDSignInDelegate {
	func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
		if let error = error {
			ALog.error(error: error)
			return
		}

		guard let authentication = user.authentication, error == nil else {
			ALog.error(error: error)
			return
		}
		Auth.auth().tenantID = AppConfig.tenantID
		let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
		Auth.auth().signIn(with: credential) { [weak self] authResult, error in
			self?.getFirebaseAuthTokenResult(authDataResult: authResult, error: error, completion: { [weak self] _ in
				self?.checkIfUserExists(user: authResult)
			})
		}
	}
}

extension AuthCoordinator: ASAuthorizationControllerDelegate {
	func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
		ALog.info("Hello Apple")

		if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
			guard let nonce = currentNonce else {
				ALog.error("Invalid state: A login callback was received, but no login request was sent.")
				return
			}
			guard let appleIDToken = appleIDCredential.identityToken else {
				ALog.info("Unable to fetch identity token")
				return
			}
			guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
				ALog.error("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
				return
			}

			let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
			Auth.auth().tenantID = AppConfig.tenantID
			Auth.auth().signIn(with: credential) { [weak self] authResult, error in
				self?.getFirebaseAuthTokenResult(authDataResult: authResult, error: error, completion: { [weak self] _ in
					self?.checkIfUserExists(user: authResult)
				})
			}
		}
	}

	func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
		ALog.error("Sign in with Apple errored:", error: error)
	}

	func signOut() {
		let firebaseAuth = Auth.auth()
		do {
			try firebaseAuth.signOut()
		} catch let signOutError as NSError {
			ALog.error("Error signing out:", error: signOutError)
		}
	}
}

extension AuthCoordinator: ASAuthorizationControllerPresentationContextProviding {
	func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
		navigationController?.visibleViewController?.view.window ?? UIWindow(frame: UIScreen.main.bounds)
	}
}
