import AuthenticationServices
import CryptoKit
import FirebaseAuth
import GoogleSignIn
import HealthKit
import JGProgressHUD
import LocalAuthentication
import os.log
import UIKit

enum SendEmailPurpose {
	case signIn
	case signUp
}

extension OSLog {
	static let authCoordinator = OSLog(subsystem: subsystem, category: "AuthCoordinator")
}

class AuthCoordinator: NSObject, Coordinator, UIViewControllerTransitioningDelegate {
	internal var navigationController: UINavigationController?
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
		self.navigationController = AuthNavigationController()
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

	internal lazy var hud: JGProgressHUD = {
		AlertHelper.progressHUD
	}()

	internal func start() {
		showOnboarding()
	}

	internal func showOnboarding() {
		let onboardingVC = OnboardingVC()
		onboardingVC.signInWithAppleAction = { [weak self] in
			self?.signInWithApple()
		}

		onboardingVC.signInWithEmailAction = { [weak self] in
			self?.goToEmailSignIn()
		}
		onboardingVC.signupAction = { [weak self] in
			self?.goToSignup()
		}
		navigate(to: onboardingVC, with: .push)
	}

	internal func goToEmailSignIn() {
		let emailSignInVC = EmailSignInVC()

		emailSignInVC.backBtnAction = { [weak self] in
			self?.navigationController?.popViewController(animated: true)
		}

		emailSignInVC.alertAction = { [weak self] title, detail, tv in
			let okAction = AlertHelper.AlertAction(withTitle: Str.ok) {
				tv.focus()
			}
			self?.showAlert(title: title, detailText: detail, actions: [okAction], fillProportionally: false)
		}

		emailSignInVC.signInWithEmail = { [weak self] email in
			self?.sendEmailLink(email: email, for: .signIn)
		}
		navigate(to: emailSignInVC, with: .push)
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
				os_log(.error, log: .authCoordinator, "Send signin Link %@", error.localizedDescription)
				AlertHelper.showAlert(title: Str.error, detailText: Str.failedSendLink, actions: [AlertHelper.AlertAction(withTitle: Str.ok)])
				return
			}

			DataContext.shared.emailForLink = email
			self?.emailrequest = email
			self?.emailSentSuccess(email: email, from: purpose)
		}
	}

	internal func emailSentSuccess(email: String, from purpose: SendEmailPurpose) {
		let emailSentVC = EmailSentVC()
		emailSentVC.email = email
		emailSentVC.purpose = purpose

		emailSentVC.backBtnAction = { [weak self] in
			self?.navigationController?.popViewController(animated: true)
		}
		emailSentVC.openMailApp = {
			guard let mailURL = URL(string: "message://") else { return }
			if UIApplication.shared.canOpenURL(mailURL) {
				UIApplication.shared.open(mailURL, options: [:], completionHandler: nil)
			}
		}
		emailSentVC.goToTermsOfService = { [weak self] in
			self?.goToTermsOfService()
		}
		emailSentVC.goToPrivacyPolicy = { [weak self] in
			self?.goToPrivacyPolicy()
		}
		navigate(to: emailSentVC, with: .push)
	}

	internal func verifySendLink(link: String) {
		if let email = DataContext.shared.emailForLink {
			goToWelcomeView(email: email, link: link)
		} else {
			start()
		}
	}

	internal func goToWelcomeView(email: String, link: String) {
		let appleHealthVC = AppleHealthVC()
		appleHealthVC.comingFrom = .welcome

		var user: AuthDataResult?

		let signInAction: (() -> Void)? = { [weak self] in
			self?.hud.show(in: self?.navigationController?.view ?? AppDelegate.primaryWindow, animated: true)
			if Auth.auth().isSignIn(withEmailLink: link) {
				Auth.auth().tenantID = nil
				Auth.auth().signIn(withEmail: email, link: link) { [weak self] authResult, error in
					appleHealthVC.comingFrom = .welcomeFailure
					if error == nil {
						self?.getFirebaseAuthTokenResult(authDataResult: authResult, error: error, completion: { [weak self] _ in
							self?.hud.dismiss(animated: true)
							user = authResult
							appleHealthVC.comingFrom = .welcomeSuccess
							appleHealthVC.setupTexts()
						})
					} else {
						self?.hud.dismiss(animated: true)
						appleHealthVC.setupTexts()
						AlertHelper.showAlert(title: error?.localizedDescription, detailText: Str.signInFailed, actions: [AlertHelper.AlertAction(withTitle: Str.ok)])
					}
				}
			} else {
				self?.hud.dismiss(animated: true)
				appleHealthVC.comingFrom = .welcomeFailure
				appleHealthVC.setupTexts()
				AlertHelper.showAlert(title: Str.error, detailText: Str.signInFailed, actions: [AlertHelper.AlertAction(withTitle: Str.ok)])
			}
		}

		appleHealthVC.nextBtnAction = { [weak self] in
			if user != nil {
				self?.checkIfUserExists(user: user)
			} else {
				self?.start()
			}
		}

		appleHealthVC.signInAction = signInAction
		navigate(to: appleHealthVC, with: .pushFullScreen)
	}

	internal func goToReset() {
		let resetVC = ResetVC()
		resetVC.backBtnAction = { [weak self] in
			self?.navigationController?.popViewController(animated: true)
		}
		resetVC.nextAction = { [weak self] email in
			self?.resetPassword(email: email)
		}
		navigate(to: resetVC, with: .push)
	}

	internal func resetPassword(email: String?) {
		hud.show(in: navigationController?.view ?? AppDelegate.primaryWindow)
		Auth.auth().sendPasswordReset(withEmail: email ?? "") { [weak self] error in
			self?.hud.dismiss(animated: true)
			if error != nil {
				AlertHelper.showAlert(title: Str.error, detailText: Str.invalidEmail, actions: [AlertHelper.AlertAction(withTitle: Str.ok)])
			} else {
				self?.goToResetMessage()
			}
		}
	}

	internal func goToResetMessage() {
		let resetMessageVC = ResetMessageVC()
		resetMessageVC.backBtnAction = { [weak self] in
			self?.navigationController?.popViewController(animated: true)
		}

		resetMessageVC.backToSignInAction = { [weak self] in
			self?.navigationController?.popViewController(animated: false)
			self?.navigationController?.popViewController(animated: true)
		}
		navigate(to: resetMessageVC, with: .push)
	}

	internal func getPatientInfo() {
		guard let user = Auth.auth().currentUser else {
			return
		}

		hud.show(in: navigationController?.view ?? AppDelegate.primaryWindow, animated: true)
		DataContext.shared.fetchData(user: user, completion: { [weak self] success in
			self?.hud.dismiss(animated: true)
			if success {
				DataContext.shared.identifyCrashlytics()
				self?.getProfile()
			} else {
				self?.goToMyProfileFirstVC(from: .signIn)
			}
		})
	}

	internal func getProfile() {
		hud.show(in: navigationController?.view ?? AppDelegate.primaryWindow, animated: true)
		DataContext.shared.getProfileAPI { [weak self] success in
			self?.hud.dismiss(animated: true)
			if success {
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
		HealthKitManager.shared.authorizeHealthKit { authorized, error in
			guard authorized else {
				let baseMessage = "HealthKit Authorization Failed"
				if let error = error {
					os_log(.error, log: .authCoordinator, "baseMessage %@. Reason: %@", baseMessage, error.localizedDescription)
				} else {
					os_log(.info, log: .authCoordinator, "baseMessage %@", baseMessage)
				}
				return
			}
			os_log(.info, log: .authCoordinator, "HealthKit Successfully Authorized.")
			DispatchQueue.main.async {
				self.syncHKData()
			}
		}
	}

	internal func syncHKData() {
		var loadingShouldAppear = true
		let hkDataUploadVC = HKDataUploadVC()
		SyncManager.shared.syncData(initialUpload: false, chunkSize: chunkSize) { [weak self] uploaded, total in
			if total > 500, loadingShouldAppear {
				loadingShouldAppear = false
				self?.navigate(to: hkDataUploadVC, with: .push)
			} else if total > 500 {
				hkDataUploadVC.progress = uploaded
				hkDataUploadVC.maxProgress = total
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
		let signupVC = SignupViewController()
		signupVC.backBtnAction = { [weak self] in
			self?.navigationController?.popViewController(animated: true)
		}
		signupVC.goToTermsOfService = { [weak self] in
			self?.goToTermsOfService()
		}
		signupVC.goToPrivacyPolicy = { [weak self] in
			self?.goToPrivacyPolicy()
		}

		signupVC.alertAction = { [weak self] title, detail, tv in
			let okAction = AlertHelper.AlertAction(withTitle: Str.ok) {
				tv.focus()
			}
			self?.showAlert(title: title, detailText: detail, actions: [okAction], fillProportionally: false)
		}

		signupVC.signUpWithEmail = { [weak self] email in
			self?.sendEmailLink(email: email, for: .signUp)
		}

		navigate(to: signupVC, with: .push)
	}

	internal func goToMyProfileFirstVC(from screen: ComingFrom = .signUp) {
		let myProfileFirstVC = MyProfileFirstVC()
		myProfileFirstVC.comingFrom = screen

		myProfileFirstVC.backBtnAction = { [weak self] in
			self?.navigationController?.popViewController(animated: true)
		}

		let sendDataAction: ((String, String, [String]) -> Void)? = { [weak self] gender, family, given in
			self?.goToMyProfileSecondVC(gender: gender, family: family, given: given)
		}

		myProfileFirstVC.alertAction = { [weak self] tv in
			let okAction = AlertHelper.AlertAction(withTitle: Str.ok) {
				tv?.focus()
			}
			self?.showAlert(title: Str.invalidText, detailText: Str.invalidTextMsg, actions: [okAction])
		}

		myProfileFirstVC.sendDataAction = sendDataAction
		navigate(to: myProfileFirstVC, with: .push)
	}

	internal func goToMyProfileSecondVC(gender: String, family: String, given: [String]) {
		let myProfileSecondVC = MyProfileSecondVC()
		myProfileSecondVC.backBtnAction = { [weak self] in
			self?.navigationController?.popViewController(animated: true)
		}

		myProfileSecondVC.patientRequestAction = { [weak self] resourceType, birthdate, weight, height, date in
			let name = Name(use: "official", family: family, given: given)
			let joinedNames = given.joined(separator: " ")
			DataContext.shared.firstName = joinedNames
			DataContext.shared.patient = Resource(code: nil, effectiveDateTime: nil, id: nil, identifier: nil, meta: nil, resourceType: resourceType, status: nil, subject: nil, valueQuantity: nil, birthDate: birthdate, gender: gender, name: [name], component: nil)
			let patient = DataContext.shared.patient
			self?.goToAppleHealthVCFromProfile(patient: patient ?? Resource(code: nil, effectiveDateTime: "", id: "", identifier: nil, meta: nil, resourceType: "", status: "", subject: nil, valueQuantity: nil, birthDate: "", gender: "", name: nil, component: nil), weight: weight, height: height, date: date)
		}

		myProfileSecondVC.alertAction = { [weak self] _ in
			let okAction = AlertHelper.AlertAction(withTitle: Str.ok) {}
			self?.showAlert(title: Str.invalidInput, detailText: Str.emptyPickerField, actions: [okAction])
		}
		navigate(to: myProfileSecondVC, with: .push)
	}

	internal func goToAppleHealthVCFromProfile(patient: Resource, weight: Int, height: Int, date: String) {
		let appleHealthVC = AppleHealthVC()
		appleHealthVC.comingFrom = .myProfile

		appleHealthVC.backBtnAction = { [weak self] in
			self?.navigationController?.popViewController(animated: true)
		}

		appleHealthVC.nextBtnAction = { [weak self] in
			self?.goToMyDevices(patient: patient, weight: weight, height: height, date: date)
		}

		navigate(to: appleHealthVC, with: .pushFullScreen)
	}

	internal func goToAppleHealthVCFromDevices() {
		let appleHealthVC = AppleHealthVC()
		appleHealthVC.comingFrom = .myDevices

		appleHealthVC.notNowAction = { [weak self] in
			self?.goToMainApp()
		}

		appleHealthVC.activateAction = { [weak self] in
			self?.authorizeHKForUpload()
		}

		navigate(to: appleHealthVC, with: .pushFullScreen)
	}

	internal func authorizeHKForUpload() {
		HealthKitManager.shared.authorizeHealthKit { [weak self] authorized, error in
			guard authorized else {
				let baseMessage = "HealthKit Authorization Failed"
				if let error = error {
					os_log(.error, log: .authCoordinator, "baseMessage %@. Reason: %@", baseMessage, error.localizedDescription)
				} else {
					os_log(.info, log: .authCoordinator, "baseMessage %@", baseMessage)
				}
				return
			}
			os_log(.info, log: .authCoordinator, "HealthKit Successfully Authorized.")
			DispatchQueue.main.async {
				self?.setChunkSize()
			}
		}
	}

	internal func setChunkSize() {
		let changeChunkSizeVC = SelectChunkSizeVC()
		let continueAction: ((Int) -> Void)? = { [weak self] chunkSize in
			self?.chunkSize = chunkSize
			self?.startInitialUpload()
		}
		changeChunkSizeVC.continueAction = continueAction
		navigate(to: changeChunkSizeVC, with: .push)
	}

	internal func startInitialUpload() {
		let hkDataUploadVC = HKDataUploadVC()
		hkDataUploadVC.queryAction = { [weak self] in
			SyncManager.shared.syncData(chunkSize: self?.chunkSize) { uploaded, total in
				hkDataUploadVC.progress = uploaded
				hkDataUploadVC.maxProgress = total
			} completion: { success in
				if success {
					self?.goToAppleHealthVCFromActivate()
				} else {
					let okAction = AlertHelper.AlertAction(withTitle: Str.ok) { [weak self] in
						self?.goToAppleHealthVCFromActivate()
					}
					AlertHelper.showAlert(title: Str.error, detailText: Str.importHealthDataFailed, actions: [okAction])
				}
			}
		}
		navigate(to: hkDataUploadVC, with: .push)
	}

	internal func goToAppleHealthVCFromActivate() {
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

		devicesVC.profileRequestAction = { [weak self] in
			self?.patientAPI(patient: patient, weight: weight, height: height, date: date)
		}
		navigate(to: devicesVC, with: .pushFullScreen)
	}

	internal func patientAPI(patient: Resource, weight: Int, height: Int, date: String) {
		hud.show(in: navigationController?.view ?? AppDelegate.primaryWindow, animated: true)
		guard DataContext.shared.userModel == nil else {
			getHeightWeight(weight: weight, height: height, date: date)
			return
		}
		AlfredClient.client.postPatient(patient: patient) { [weak self] result in
			self?.hud.dismiss(animated: true)
			DataContext.shared.patient = patient
			switch result {
			case .success(let patientResponse):
				os_log(.info, log: .authCoordinator, "OK STATUS FOR PATIENT : 200")
				let defaultName = Name(use: "", family: "", given: [""])
				DataContext.shared.userModel = UserModel(userID: patientResponse.id ?? "", email: self?.emailrequest ?? "", name: patientResponse.name ?? [defaultName], dob: patient.birthDate, gender: Gender(rawValue: DataContext.shared.patient?.gender ?? ""))
				self?.getHeightWeight(weight: weight, height: height, date: date)
			case .failure(let error):
				os_log(.error, log: .authCoordinator, "request failed %@", error.localizedDescription)
				AlertHelper.showAlert(title: Str.error, detailText: Str.createPatientFailed, actions: [AlertHelper.AlertAction(withTitle: Str.ok)])
				return
			}
		}
	}

	internal func getHeightWeight(weight: Int, height: Int, date: String) {
		let weightObservation = Resource(code: DataContext.shared.weightCode, effectiveDateTime: date, id: nil, identifier: nil, meta: nil, resourceType: "Observation", status: "final", subject: Subject(reference: DataContext.shared.patientID, type: "Patient", identifier: nil, display: DataContext.shared.displayName), valueQuantity: ValueQuantity(value: weight, unit: Str.weightUnit), birthDate: nil, gender: nil, name: nil, component: nil)

		let weightEntry = Entry(fullURL: nil, resource: weightObservation, request: BERequest(method: "POST", url: "Observation"), search: nil, response: nil)

		let heightObservation = Resource(code: DataContext.shared.heightCode, effectiveDateTime: date, id: nil, identifier: nil, meta: nil, resourceType: "Observation", status: "final", subject: Subject(reference: DataContext.shared.patientID, type: "Patient", identifier: nil, display: DataContext.shared.displayName), valueQuantity: ValueQuantity(value: height, unit: Str.heightUnit), birthDate: nil, gender: nil, name: nil, component: nil)

		let heightEntry = Entry(fullURL: nil, resource: heightObservation, request: BERequest(method: "POST", url: "Observation"), search: nil, response: nil)

		let bundle = BundleModel(entry: [weightEntry, heightEntry], link: nil, resourceType: "Bundle", total: nil, type: "transaction")

		bundleAction(bundle: bundle)
	}

	internal func bundleAction(bundle: BundleModel) {
		hud.show(in: navigationController?.view ?? AppDelegate.primaryWindow, animated: true)
		AlfredClient.client.postBundle(bundle: bundle) { [weak self] result in
			self?.hud.dismiss(animated: true)
			switch result {
			case .success(let response):
				os_log(.info, log: .authCoordinator, "response %@", String(describing: response))
				DataContext.shared.signUpCompleted = true
				let profile = DataContext.shared.createProfileModel()
				self?.profileRequest(profile: profile)
			case .failure(let error):
				os_log(.error, log: .authCoordinator, "request failed %@", error.localizedDescription)
				AlertHelper.showAlert(title: Str.error, detailText: Str.createBundleFailed, actions: [AlertHelper.AlertAction(withTitle: Str.ok)])
			}
		}
	}

	internal func profileRequest(profile: ProfileModel) {
		hud.show(in: navigationController?.view ?? AppDelegate.primaryWindow, animated: true)
		AlfredClient.client.postProfile(profile: profile) { [weak self] result in
			self?.hud.dismiss(animated: true)
			switch result {
			case .success(let resource):
				DataContext.shared.identifyCrashlytics()
				os_log(.info, log: .authCoordinator, "OK STATUS FOR PROFILE: 200 %@, %@", String(describing: DataContext.shared.signUpCompleted), String(describing: resource))
				self?.goToAppleHealthVCFromDevices()
			case .failure(let error):
				os_log(.error, log: .authCoordinator, "request failed %@", error.localizedDescription)
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

	func signInWithApple() {
		let request = startSignInWithAppleFlow()
		let authorizationController = ASAuthorizationController(authorizationRequests: [request])
		authorizationController.delegate = self
		authorizationController.presentationContextProvider = self
		authorizationController.performRequests()
		os_log(.info, log: .authCoordinator, "Got in startSignInWithApple")
	}

	func startSignInWithAppleFlow() -> ASAuthorizationOpenIDRequest {
		let appleIDProvider = ASAuthorizationAppleIDProvider()
		let request = appleIDProvider.createRequest()
		request.requestedScopes = [.fullName, .email]
		let nonce = AppleSecurityManager.randomNonceString()
		request.nonce = AppleSecurityManager.sha256(nonce)
		currentNonce = nonce
		os_log(.info, log: .authCoordinator, "nonce: %@", nonce)
		return request
	}

	private func getFirebaseAuthTokenResult(authDataResult: AuthDataResult?, error: Error?, completion: @escaping (Bool) -> Void) {
		if let error = error {
			os_log(.error, log: .authCoordinator, "%@", error.localizedDescription)
			hud.dismiss()
			AlertHelper.showAlert(title: Str.error, detailText: Str.signInFailed, actions: [AlertHelper.AlertAction(withTitle: Str.ok)])
		} else if let authDataResult = authDataResult {
			authDataResult.user.getIDTokenResult { [weak self] authTokenResult, _ in
				self?.hud.dismiss(animated: true)
				if let error = error {
					os_log(.error, log: .authCoordinator, "%@", error.localizedDescription)
					AlertHelper.showAlert(title: Str.error, detailText: Str.signInFailed, actions: [AlertHelper.AlertAction(withTitle: Str.ok)])
					completion(false)
				} else if let authTokenResult = authTokenResult {
					self?.emailrequest = Auth.auth().currentUser?.email
					DataContext.shared.authToken = authTokenResult.token
					os_log(.info, log: .authCoordinator, "firebaseToken: %{private}@", authTokenResult.token)
					completion(true)
				}
			}
		}
	}

	private func checkIfUserExists(user: AuthDataResult?) {
		let newUser = user?.additionalUserInfo?.isNewUser
		if newUser == true {
			goToMyProfileFirstVC()
		} else {
			getPatientInfo()
		}
	}
}

extension AuthCoordinator: GIDSignInDelegate {
	func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
		if let error = error {
			os_log(.error, log: .authCoordinator, "%@", error.localizedDescription)
			return
		}

		guard let authentication = user.authentication, error == nil else {
			os_log(.error, log: .authCoordinator, "%@", error?.localizedDescription ?? "")
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
		os_log(.info, log: .authCoordinator, "Hello Apple")

		if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
			guard let nonce = currentNonce else {
				fatalError("Invalid state: A login callback was received, but no login request was sent.")
			}
			guard let appleIDToken = appleIDCredential.identityToken else {
				os_log(.error, log: .authCoordinator, "Unable to fetch identity token")
				return
			}
			guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
				os_log(.error, log: .authCoordinator, "Unable to serialize token string from data: %@", appleIDToken.debugDescription)
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
		os_log(.error, log: .authCoordinator, "Sign in with Apple errored: %@", error.localizedDescription)
	}

	func signOut() {
		let firebaseAuth = Auth.auth()
		do {
			try firebaseAuth.signOut()
		} catch let signOutError as NSError {
			os_log(.error, log: .authCoordinator, "Error signing out: %@", signOutError.localizedDescription)
		}
	}
}

extension AuthCoordinator: ASAuthorizationControllerPresentationContextProviding {
	func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
		navigationController?.visibleViewController?.view.window ?? UIWindow(frame: UIScreen.main.bounds)
	}
}
