//
//  AuthCoordinator.swift
//  Allie
//

import AuthenticationServices
import CareKitStore
import CryptoKit
import FirebaseAuth
import GoogleSignIn
import HealthKit
import LocalAuthentication
import UIKit

class AuthCoordinator: NSObject, Coordinable, UIViewControllerTransitioningDelegate {
	let type: CoordinatorType = .authCoordinator

	var navigationController: UINavigationController? = {
		UINavigationController()
	}()

	var childCoordinators: [CoordinatorType: Coordinable] = [:]
	weak var parentCoordinator: MainCoordinator?

	var currentNonce: String?
	var emailrequest: String?
	var authorizationFlowType: AuthorizationFlowType = .signUp

	var rootViewController: UIViewController? {
		navigationController
	}

	init(parentCoordinator parent: MainCoordinator?, deepLink: String = "") {
		self.parentCoordinator = parent
		super.init()
		GIDSignIn.sharedInstance().delegate = self

		if deepLink != "" {
			verifySendLink(link: deepLink)
		} else {
			start()
		}
	}

	func start() {
		gotoOnboarding()
	}

	func showHUD(animated: Bool = true) {
		parentCoordinator?.showHUD(animated: animated)
	}

	func hideHUD(animated: Bool = true) {
		parentCoordinator?.hideHUD(animated: animated)
	}

	func gotoOnboarding(authorizationFlowType type: AuthorizationFlowType = .signUp) {
		authorizationFlowType = type
		let onboardingViewController = OnboardingViewController()
		onboardingViewController.authorizationFlowType = type
		onboardingViewController.appleAuthoizationAction = { [weak self] in
			self?.signInWithApple()
		}

		onboardingViewController.emailAuthorizationAction = { [weak self] authorizationFlowType in
			self?.authorizationFlowType = authorizationFlowType
			self?.gotoEmailAuthorization()
		}

		onboardingViewController.authorizationFlowChangedAction = { [weak self] authorizationFlowType in
			self?.gotoOnboarding(authorizationFlowType: authorizationFlowType)
		}
		navigate(to: onboardingViewController, with: .resetStack)
	}

	func gotoEmailAuthorization() {
		let emailAuthViewController = EmailAuthorizationViewController()
		emailAuthViewController.authorizationFlowType = authorizationFlowType
		emailAuthViewController.alertAction = { [weak self] title, detail, textField in
			let okAction = AlertHelper.AlertAction(withTitle: Str.ok) {
				_ = textField.becomeFirstResponder()
			}
			self?.showAlert(title: title, detailText: detail, actions: [okAction], fillProportionally: false)
		}

		emailAuthViewController.gotoTermsOfService = { [weak self] in
			self?.gotoTermsOfService()
		}
		emailAuthViewController.gotoPrivacyPolicy = { [weak self] in
			self?.gotoPrivacyPolicy()
		}

		emailAuthViewController.authorizeWithEmail = { [weak self] email, _ in
			self?.sendEmailLink(email: email)
		}

		navigate(to: emailAuthViewController, with: .push)
	}

	func sendEmailLink(email: String) {
		let bundleId = Bundle.main.bundleIdentifier!
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

			Keychain.emailForLink = email
			self?.emailrequest = email
			self?.emailSentSuccess(email: email)
		}
	}

	internal func emailSentSuccess(email: String) {
		let emailSentViewController = EmailSentViewController()
		emailSentViewController.email = email
		emailSentViewController.authorizationFlowType = authorizationFlowType

		emailSentViewController.openMailApp = {
			guard let mailURL = URL(string: "message://") else { return }
			UIApplication.shared.open(mailURL, options: [:]) { success in
				if success == false {
					ALog.info("Unable to open mail account")
				}
			}
		}
		emailSentViewController.goToTermsOfService = { [weak self] in
			self?.gotoTermsOfService()
		}
		emailSentViewController.goToPrivacyPolicy = { [weak self] in
			self?.gotoPrivacyPolicy()
		}
		navigate(to: emailSentViewController, with: .push)
	}

	internal func verifySendLink(link: String) {
		if let email = Keychain.emailForLink {
			gotoWelcomeView(email: email, link: link)
		} else {
			start()
		}
	}

	internal func gotoWelcomeView(email: String, link: String) {
		let healthViewController = HealthViewController()
		healthViewController.screenFlowType = .welcome
		healthViewController.authorizationFlowType = authorizationFlowType
		var authDataResult: AuthDataResult?
		let signInAction: (() -> Void)? = { [weak self, weak healthViewController] in
			self?.showHUD()
			if Auth.auth().isSignIn(withEmailLink: link) {
				Auth.auth().signIn(withEmail: email, link: link) { [weak self] authResult, error in
					if error == nil {
						self?.getFirebaseAuthTokenResult(authDataResult: authResult, error: error, completion: { [weak self] _ in
							DispatchQueue.main.async {
								authDataResult = authResult
								if let viewController = healthViewController, viewController.authorizationFlowType == .signIn {
									self?.parentCoordinator?.gotoHealthKitAuthorization()
								} else {
									healthViewController?.screenFlowType = .welcomeSuccess
								}
							}
						})
					} else {
						DispatchQueue.main.async {
							self?.hideHUD()
							healthViewController?.screenFlowType = .welcomeFailure
							AlertHelper.showAlert(title: error?.localizedDescription, detailText: Str.signInFailed, actions: [AlertHelper.AlertAction(withTitle: Str.ok)])
						}
					}
				}
			} else {
				self?.hideHUD()
				healthViewController?.screenFlowType = .welcomeFailure
				AlertHelper.showAlert(title: Str.error, detailText: Str.signInFailed, actions: [AlertHelper.AlertAction(withTitle: Str.ok)])
			}
		}

		healthViewController.nextButtonAction = { [weak self, weak healthViewController] in
			if let viewController = healthViewController, viewController.screenFlowType == .welcomeSuccess, viewController.authorizationFlowType == .signIn {
				self?.parentCoordinator?.gotoHealthKitAuthorization()
			} else if authDataResult != nil {
				self?.checkIfUserExists(user: authDataResult)
			} else {
				self?.start()
			}
		}

		healthViewController.signInAction = signInAction
		navigate(to: healthViewController, with: .pushFullScreen)
	}

	internal func gotoReset() {
		let resetViewController = ResetViewController()
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
		APIClient.client.getCarePlan { [weak self] carePlanResult in
			self?.hideHUD()
			switch carePlanResult {
			case .failure(let error):
				ALog.error("Unable to fetch CarePlan: ", error: error)
				self?.gotoProfileSetupViewController(user: user)
			case .success(let carePlan):
				if let patient = carePlan.allPatients.first {
					LoggingManager.identify(userId: patient.id)
					let ockPatient = OCKPatient(patient: patient)
					try? AppDelegate.careManager.resetAllContents()
					self?.careManager.createOrUpdate(patient: ockPatient) { patientResult in
						switch patientResult {
						case .failure(let error):
							ALog.error("Unable to add patient to store", error: error)
						case .success:
							self?.parentCoordinator?.gotoHealthKitAuthorization()
						}
					}
				} else {
					self?.gotoProfileSetupViewController(user: user)
				}
			}
		}
	}

	public func gotoMainApp() {
		parentCoordinator?.gotoMainApp()
	}

	var patient: AlliePatient!

	func gotoProfileSetupViewController(user: RemoteUser) {
		try? careManager.resetAllContents()
		patient = AlliePatient(user: user)
		gotoProfileNameEntryViewController()
	}

	func gotoProfileNameEntryViewController(from screen: NavigationSourceType = .signUp) {
		let myProfileFirstViewController = ProfileNameEntryViewController()
		myProfileFirstViewController.comingFrom = screen
		let sendDataAction: ((OCKBiologicalSex, String, [String]) -> Void)? = { [weak self] gender, family, given in
			self?.gotoProfileDataEntryViewController(gender: gender, family: family, given: given)
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

	func gotoProfileDataEntryViewController(gender: OCKBiologicalSex, family: String, given: [String]) {
		let myProfileSecondViewController = ProfileDataEntryViewController()
		myProfileSecondViewController.patientRequestAction = { [weak self] _, birthday, weight, height, effectiveDate in
			var givenNames = given
			self?.patient?.name.givenName = givenNames.first
			givenNames.removeFirst()
			self?.patient?.name.middleName = givenNames.joined(separator: " ")
			self?.patient?.name.familyName = family
			self?.patient?.sex = gender
			self?.patient?.effectiveDate = effectiveDate
			self?.patient?.birthday = birthday
			self?.patient?.weight = weight
			self?.patient?.height = height
			self?.gotoHealthViewController(screenFlowType: .selectDevices)
		}

		myProfileSecondViewController.alertAction = { [weak self] _ in
			let okAction = AlertHelper.AlertAction(withTitle: Str.ok) {}
			self?.showAlert(title: Str.invalidInput, detailText: Str.emptyPickerField, actions: [okAction])
		}
		navigate(to: myProfileSecondViewController, with: .push)
	}

	func gotoHealthViewController(screenFlowType: ScreenFlowType) {
		let healthViewController = HealthViewController()
		healthViewController.screenFlowType = screenFlowType
		healthViewController.authorizationFlowType = authorizationFlowType
		healthViewController.nextButtonAction = { [weak self] in
			if screenFlowType == .selectDevices {
				self?.gotoMyDevices()
			} else {
				self?.createPatient()
			}
		}

		healthViewController.notNowAction = { [weak self] in
			self?.createPatient()
		}

		healthViewController.activateAction = { [weak self] in
			self?.authorizeHKForUpload()
		}

		navigate(to: healthViewController, with: .pushFullScreen)
	}

	func createPatient() {
		patient.isSignUpCompleted = true
		showHUD()
		APIClient.client.postPatient(patient: patient) { [weak self] result in
			self?.hideHUD()
			switch result {
			case .failure(let error):
				let okAction = AlertHelper.AlertAction(withTitle: Str.ok) {
					DispatchQueue.main.async {
						self?.gotoMainApp()
					}
				}
				self?.showAlert(title: "Unable to create Patient", detailText: error.localizedDescription, actions: [okAction])
			case .success:
				self?.gotoMainApp()
			}
		}
	}

	func authorizeHKForUpload() {
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

	func setChunkSize() {
		let changeChunkSizeViewController = SelectChunkSizeViewController()
		let continueAction: ((Int) -> Void)? = { [weak self] chunkSize in
			UserDefaults.standard.healthKitUploadChunkSize = chunkSize
			self?.gotoHealthViewController(screenFlowType: .activate)
		}
		changeChunkSizeViewController.continueAction = continueAction
		navigate(to: changeChunkSizeViewController, with: .push)
	}

	func startInitialUpload() {
		let hkDataUploadViewController = HKDataUploadViewController()
		hkDataUploadViewController.queryAction = { [weak self] in
			HealthKitSyncManager.syncData(chunkSize: UserDefaults.standard.healthKitUploadChunkSize) { uploaded, total in
				hkDataUploadViewController.progress = uploaded
				hkDataUploadViewController.maxProgress = total
			} completion: { success in
				if success {
					self?.gotoHealthViewController(screenFlowType: .activate)
				} else {
					let okAction = AlertHelper.AlertAction(withTitle: Str.ok) { [weak self] in
						self?.gotoHealthViewController(screenFlowType: .activate)
					}
					AlertHelper.showAlert(title: Str.error, detailText: Str.importHealthDataFailed, actions: [okAction])
				}
			}
		}
		navigate(to: hkDataUploadViewController, with: .push)
	}

	func gotoMyDevices() {
		let devicesViewController = DevicesSelectionViewController()
		devicesViewController.nextButtonAction = { [weak self] in
			self?.gotoHealthViewController(screenFlowType: .healthKit)
		}
		navigate(to: devicesViewController, with: .pushFullScreen)
	}

	func gotoPrivacyPolicy() {
		let privacyPolicyViewController = HTMLViewerController()
		privacyPolicyViewController.title = Str.privacyPolicy
		navigate(to: privacyPolicyViewController, with: .pushFullScreen)
	}

	func gotoTermsOfService() {
		let termsOfServiceViewController = HTMLViewerController()
		termsOfServiceViewController.title = Str.termsOfService
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
			authDataResult.user.getIDTokenResult { [weak self] tokenResult, error in
				self?.hideHUD()
				if let error = error {
					ALog.info("\(error.localizedDescription)")
					AlertHelper.showAlert(title: Str.error, detailText: Str.signInFailed, actions: [AlertHelper.AlertAction(withTitle: Str.ok)])
					completion(false)
				} else if let authToken = tokenResult?.token {
					self?.emailrequest = Auth.auth().currentUser?.email
					Keychain.authToken = authToken
					ALog.info("firebaseToken: \(authToken)")
					completion(true)
				}
			}
		}
	}

	private func checkIfUserExists(user: AuthDataResult?) {
		let newUser = user?.additionalUserInfo?.isNewUser
		if newUser == true {
			gotoProfileSetupViewController(user: (user?.user)!)
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
