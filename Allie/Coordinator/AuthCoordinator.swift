//
//  AuthCoordinator.swift
//  Allie
//

import AuthenticationServices
import CareKitStore
import Combine
import CryptoKit
import FirebaseAuth
import GoogleSignIn
import HealthKit
import LocalAuthentication
import UIKit

class AuthCoordinator: NSObject, Coordinable, UIViewControllerTransitioningDelegate {
	let type: CoordinatorType = .authCoordinator
	var cancellables: Set<AnyCancellable> = []

	var navigationController: UINavigationController? = {
		UINavigationController()
	}()

	var childCoordinators: [CoordinatorType: Coordinable] = [:]
	weak var parentCoordinator: MainCoordinator?

	var currentNonce: String?
	var emailrequest: String?
	var authorizationFlowType: AuthorizationFlowType = .signUp
	var alliePatient: AlliePatient?

	var rootViewController: UIViewController? {
		navigationController
	}

	init(parentCoordinator parent: MainCoordinator?, deepLink: String?) {
		self.parentCoordinator = parent
		super.init()
		GIDSignIn.sharedInstance().delegate = self

		if let link = deepLink {
			verifySendLink(link: link)
		} else {
			start()
		}
	}

	func start() {
		gotoSignup()
	}

	func showHUD(animated: Bool = true) {
		parentCoordinator?.showHUD(animated: animated)
	}

	func hideHUD(animated: Bool = true) {
		parentCoordinator?.hideHUD(animated: animated)
	}

	func gotoSignup(authorizationFlowType type: AuthorizationFlowType = .signUp) {
		authorizationFlowType = type
		let signupViewController = SignupViewController()
		signupViewController.authorizationFlowType = type
		signupViewController.appleAuthoizationAction = { [weak self] in
			self?.signInWithApple()
		}

		signupViewController.emailAuthorizationAction = { [weak self] authorizationFlowType in
			self?.authorizationFlowType = authorizationFlowType
			self?.gotoEmailSignup()
		}

		signupViewController.authorizationFlowChangedAction = { [weak self] authorizationFlowType in
			switch authorizationFlowType {
			case .signIn:
				self?.gotoLogin(authorizationFlowType: authorizationFlowType)
			case .signUp:
				self?.gotoSignup(authorizationFlowType: authorizationFlowType)
			}
		}
		navigate(to: signupViewController, with: .resetStack)
	}

	func gotoLogin(authorizationFlowType type: AuthorizationFlowType = .signIn) {
		authorizationFlowType = type
		let loginViewController = LoginViewController()
		loginViewController.authorizationFlowType = type
		loginViewController.appleAuthoizationAction = { [weak self] in
			self?.signInWithApple()
		}

		loginViewController.authorizeWithEmail = { [weak self] email, authorizationFlowType in
			self?.authorizationFlowType = authorizationFlowType
			self?.sendEmailLink(email: email)
		}

		loginViewController.authorizationFlowChangedAction = { [weak self] authorizationFlowType in
			switch authorizationFlowType {
			case .signIn:
				self?.gotoLogin(authorizationFlowType: authorizationFlowType)
			case .signUp:
				self?.gotoSignup(authorizationFlowType: authorizationFlowType)
			}
		}
		navigate(to: loginViewController, with: .resetStack)
	}

	func gotoEmailSignup() {
		let emailSignupViewController = EmailSignupViewController()
		emailSignupViewController.authorizeWithEmail = { [weak self] email, authorizationFlowType in
			self?.authorizationFlowType = authorizationFlowType
			self?.sendEmailLink(email: email)
		}
		navigate(to: emailSignupViewController, with: .resetStack)
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

	func emailSentSuccess(email: String) {
		let emailSentViewController = EmailSentViewController()
		emailSentViewController.authorizationFlowType = authorizationFlowType
		emailSentViewController.openMailApp = {
			guard let mailURL = URL(string: "message://") else { return }
			UIApplication.shared.open(mailURL, options: [:]) { success in
				if success == false {
					ALog.info("Unable to open mail account")
				}
			}
		}
		navigate(to: emailSentViewController, with: .resetStack)
	}

	func verifySendLink(link: String) {
		if let email = Keychain.emailForLink {
			showHUD()
			if Auth.auth().isSignIn(withEmailLink: link) {
				Auth.auth().signIn(withEmail: email, link: link) { [weak self] authResult, error in
					if error == nil {
						self?.getFirebaseAuthTokenResult(authDataResult: authResult, error: error, completion: { _ in
							DispatchQueue.main.async {
								if let authorizationFlowType = self?.authorizationFlowType, authorizationFlowType == .signIn {
									if HealthKitManager.shared.healthKitAuthorized == false {
										self?.gotoHealthViewController(screenFlowType: .healthKit)
									} else {
										self?.gotoMainApp()
									}
								} else {
									self?.checkIfUserExists(email: email, user: authResult)
								}
							}
						})
					} else {
						DispatchQueue.main.async {
							AlertHelper.showAlert(title: error?.localizedDescription, detailText: Str.signInFailed, actions: [AlertHelper.AlertAction(withTitle: Str.ok)])
						}
					}
				}
			}
		} else {
			AlertHelper.showAlert(title: Str.error, detailText: Str.signInFailed, actions: [AlertHelper.AlertAction(withTitle: Str.ok)])
			start()
		}
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

	internal func getPatient(email: String?, user: RemoteUser) {
		guard let user = Auth.auth().currentUser else {
			gotoSignup()
			return
		}
		showHUD()
		APIClient.client.getCarePlan { [weak self] carePlanResult in
			self?.hideHUD()
			switch carePlanResult {
			case .failure(let error):
				ALog.error("Unable to fetch CarePlan: ", error: error)
				self?.gotoProfileSetupViewController(email: email, user: user)
			case .success(let carePlan):
				if let patient = carePlan.patients.first {
					self?.alliePatient = patient
					let ockPatient = OCKPatient(patient: patient)
					try? AppDelegate.careManager.resetAllContents()
					self?.careManager.createOrUpdate(patient: ockPatient) { patientResult in
						switch patientResult {
						case .failure(let error):
							ALog.error("Unable to add patient to store", error: error)
							self?.gotoProfileSetupViewController(email: email, user: user)
						case .success:
							self?.parentCoordinator?.gotoHealthKitAuthorization()
						}
					}
				} else {
					self?.gotoProfileSetupViewController(email: email, user: user)
				}
			}
		}
	}

	public func gotoMainApp() {
		parentCoordinator?.refreshRemoteConfig(completion: { [weak self] _ in
			self?.careManager.patient = self?.alliePatient
			self?.parentCoordinator?.gotoMainApp()
		})
	}

	func gotoProfileSetupViewController(email: String?, user: RemoteUser) {
		try? careManager.resetAllContents()
		if alliePatient == nil {
			alliePatient = AlliePatient(user: user)
		}
		if let email = email {
			alliePatient?.profile.email = email
		}
		gotoProfileEntryViewController()
	}

	func gotoProfileEntryViewController(from screen: NavigationSourceType = .signUp) {
		let viewController = ProfileEntryViewController()
		viewController.fullName = alliePatient?.name.fullName
		viewController.sex = alliePatient?.sex ?? .male
		if let dob = alliePatient?.birthday {
			viewController.dateOfBirth = dob
		}
		if let weight = alliePatient?.profile.weightInPounds {
			viewController.weightInPounds = weight
		}
		if let height = alliePatient?.profile.heightInInches {
			viewController.heightInInches = height
		}
		viewController.doneAction = { [weak self] in
			if let name = PersonNameComponents(fullName: viewController.fullName) {
				self?.alliePatient?.name = name
			}
			self?.alliePatient?.sex = viewController.sex
			self?.alliePatient?.updatedDate = Date()
			self?.alliePatient?.birthday = viewController.dateOfBirth
			self?.alliePatient?.profile.weightInPounds = viewController.weightInPounds
			self?.alliePatient?.profile.heightInInches = viewController.heightInInches
			self?.gotoMyDevices()
		}
		navigate(to: viewController, with: .resetStack)
	}

	func gotoHealthViewController(screenFlowType: ScreenFlowType) {
		let healthViewController = HealthViewController()
		healthViewController.screenFlowType = screenFlowType
		healthViewController.authorizationFlowType = authorizationFlowType
		healthViewController.notNowAction = { [weak self] in
			self?.createPatient()
		}

		healthViewController.activateAction = { [weak self] in
			self?.authorizeHKForUpload()
		}

		navigate(to: healthViewController, with: .resetStack)
	}

	func createPatient() {
		alliePatient?.profile.isSignUpCompleted = true
		showHUD()
		APIClient.client.postPatient(patient: alliePatient!) { [weak self] result in
			self?.hideHUD()
			switch result {
			case .failure(let error):
				let okAction = AlertHelper.AlertAction(withTitle: Str.ok) {
					DispatchQueue.main.async {
						self?.gotoMainApp()
					}
				}
				self?.showAlert(title: "Unable to create Patient", detailText: error.localizedDescription, actions: [okAction])
			case .success(let carePlan):
				if let patient = carePlan.patients.first {
					self?.careManager.patient = patient
				}
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
				UserDefaults.standard.healthKitUploadChunkSize = 4500
				self?.gotoMainApp()
			}
		}
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
		navigate(to: devicesViewController, with: .resetStack)
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
		let request = createAuthorizationAppleIDRequest()
		let authorizationController = ASAuthorizationController(authorizationRequests: [request])
		authorizationController.delegate = self
		authorizationController.presentationContextProvider = self
		authorizationController.performRequests()
		ALog.info("Got in startSignInWithApple")
	}

	func createAuthorizationAppleIDRequest() -> ASAuthorizationOpenIDRequest {
		let appleIDProvider = ASAuthorizationAppleIDProvider()
		let request = appleIDProvider.createRequest()
		request.requestedScopes = [.fullName, .email]
		let nonce = AppleSecurityManager.randomNonceString()
		request.nonce = AppleSecurityManager.sha256(nonce)
		currentNonce = nonce
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

	private func checkIfUserExists(email: String?, user: AuthDataResult?) {
		let newUser = user?.additionalUserInfo?.isNewUser
		if newUser == true {
			gotoProfileSetupViewController(email: email, user: (user?.user)!)
		} else {
			getPatient(email: email, user: (user?.user)!)
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
				if let authUser = authResult?.user {
					var alliePatient = AlliePatient(user: authUser)
					var name = PersonNameComponents()
					if let givenName = user.profile.givenName {
						name.givenName = givenName
					}
					if let familyName = user.profile.familyName {
						name.familyName = familyName
					}
					if alliePatient?.profile.email == nil {
						alliePatient?.profile.email = user.profile.email
					}
					self?.alliePatient = alliePatient
				}

				self?.checkIfUserExists(email: user.profile.email, user: authResult)
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
					if let user = authResult?.user {
						var alliePatient = AlliePatient(user: user)
						if let name = appleIDCredential.fullName {
							alliePatient?.name = name
						}
						if alliePatient?.profile.email == nil {
							alliePatient?.profile.email = appleIDCredential.email
						}
						self?.alliePatient = alliePatient
					}
					self?.checkIfUserExists(email: appleIDCredential.email, user: authResult)
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
