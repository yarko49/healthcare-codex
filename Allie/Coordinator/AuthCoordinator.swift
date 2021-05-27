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
import KeychainAccess
import UIKit

class AuthCoordinator: BaseCoordinator {
	weak var parent: MainCoordinator?

	var currentNonce: String?
	var authorizationFlowType: AuthorizationFlowType = .signUp
	var alliePatient: AlliePatient?

	override var rootViewController: UIViewController? {
		navigationController
	}

	init(parent: MainCoordinator?, deepLink: String?) {
		super.init(type: .authentication)
		navigationController = UINavigationController()
		self.parent = parent
		parent?.window.rootViewController = SplashViewController()
		GIDSignIn.sharedInstance().delegate = self
		if let link = deepLink {
			verifySendLink(link: link)
		} else {
			start()
		}
	}

	override func start() {
		gotoSignup()
	}

	func showHUD(title: String? = nil, message: String? = nil, animated: Bool = true) {
		parent?.showHUD(title: title, message: message, animated: animated)
	}

	func hideHUD(animated: Bool = true) {
		parent?.hideHUD(animated: animated)
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
		navigate(to: loginViewController, with: .push)
	}

	func gotoEmailSignup() {
		let emailSignupViewController = EmailSignupViewController()
		emailSignupViewController.authorizeWithEmail = { [weak self] email, authorizationFlowType in
			self?.authorizationFlowType = authorizationFlowType
			self?.sendEmailLink(email: email)
		}
		navigate(to: emailSignupViewController, with: .push)
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
				AlertHelper.showAlert(title: String.error, detailText: String.failedSendLink, actions: [AlertHelper.AlertAction(withTitle: String.ok)])
				return
			}

			Keychain.userEmail = email
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
		navigate(to: emailSentViewController, with: .push)
	}

	func verifySendLink(link: String) {
		if let email = Keychain.userEmail {
			showHUD()
			if Auth.auth().isSignIn(withEmailLink: link) {
				Auth.auth().signIn(withEmail: email, link: link) { [weak self] authResult, error in
					if error == nil {
						self?.getFirebaseAuthTokenResult(authDataResult: authResult, error: error, completion: { _ in
							DispatchQueue.main.async {
								if let authorizationFlowType = self?.authorizationFlowType, authorizationFlowType == .signIn {
									HealthKitManager.shared.authorizeHealthKit { _, _ in
										DispatchQueue.main.async {
											self?.parent?.gotoMainApp()
										}
									}
								} else {
									self?.checkIfUserExists(email: email, user: authResult)
								}
							}
						})
					} else {
						DispatchQueue.main.async {
							AlertHelper.showAlert(title: error?.localizedDescription, detailText: String.signInFailed, actions: [AlertHelper.AlertAction(withTitle: String.ok)])
						}
					}
				}
			}
		} else {
			AlertHelper.showAlert(title: String.error, detailText: String.signInFailed, actions: [AlertHelper.AlertAction(withTitle: String.ok)])
			start()
		}
	}

	func getPatient(email: String?, user: RemoteUser) {
		guard let user = Auth.auth().currentUser else {
			gotoSignup()
			return
		}
		showHUD()
		APIClient.shared.getCarePlan { [weak self] carePlanResult in
			self?.hideHUD()
			switch carePlanResult {
			case .failure(let error):
				ALog.error("Unable to fetch CarePlan: ", error: error)
				self?.gotoProfileSetupViewController(email: email, user: user)
			case .success(let carePlan):
				if let patient = carePlan.patients.first {
					self?.alliePatient = patient
					let ockPatient = OCKPatient(patient: patient)
					try? CareManager.shared.resetAllContents()
					CareManager.shared.createOrUpdate(patient: ockPatient) { patientResult in
						switch patientResult {
						case .failure(let error):
							ALog.error("Unable to add patient to store", error: error)
							self?.gotoProfileSetupViewController(email: email, user: user)
						case .success:
							self?.parent?.gotoHealthKitAuthorization()
						}
					}
				} else {
					self?.gotoProfileSetupViewController(email: email, user: user)
				}
			}
		}
	}

	func gotoProfileSetupViewController(email: String?, user: RemoteUser) {
		try? CareManager.shared.resetAllContents()
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
		viewController.patient = alliePatient
		viewController.doneAction = { [weak self] in
			if let name = PersonNameComponents(fullName: viewController.fullName) {
				self?.alliePatient?.name = name
			}
			self?.alliePatient?.sex = viewController.sex
			self?.alliePatient?.updatedDate = Date()
			self?.alliePatient?.birthday = viewController.dateOfBirth
			self?.alliePatient?.profile.weightInPounds = viewController.weightInPounds
			self?.alliePatient?.profile.heightInInches = viewController.heightInInches
			self?.createPatient()
		}
		navigate(to: viewController, with: .push)
	}

	func gotoHealthViewController(screenFlowType: ScreenFlowType) {
		let healthViewController = HealthViewController()
		healthViewController.screenFlowType = screenFlowType
		healthViewController.authorizationFlowType = authorizationFlowType
		healthViewController.notNowAction = { [weak self] in
			DispatchQueue.main.async {
				self?.parent?.gotoMainApp()
			}
		}

		healthViewController.activateAction = { [weak self] in
			self?.authorizeHKForUpload()
		}

		navigate(to: healthViewController, with: .push)
	}

	func createPatient() {
		alliePatient?.profile.isSignUpCompleted = true
		CareManager.shared.patient = alliePatient
		let title = NSLocalizedString("CREATING_ACCOUNT", comment: "Creating Account")
		showHUD(title: title, message: nil, animated: true)
		APIClient.shared.post(patient: alliePatient!) { [weak self] result in
			switch result {
			case .failure(let error):
				let okAction = AlertHelper.AlertAction(withTitle: String.ok) {
					self?.parent?.refreshRemoteConfig(completion: { [weak self] _ in
						self?.hideHUD()
						self?.gotoMyDevices()
					})
				}
				self?.showAlert(title: "Unable to create Patient", detailText: error.localizedDescription, actions: [okAction])
			case .success(let carePlanResponse):
				if let patient = carePlanResponse.patients.first {
					CareManager.shared.patient = patient
				}
				self?.parent?.refreshRemoteConfig(completion: { [weak self] _ in
					self?.hideHUD()
					self?.gotoMyDevices()
				})
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
				self?.parent?.gotoMainApp()
			}
		}
	}

	func gotoMyDevices() {
		let devicesViewController = DevicesSelectionViewController()
		devicesViewController.nextButtonAction = { [weak self] in
			self?.gotoHealthViewController(screenFlowType: .healthKit)
		}
		navigate(to: devicesViewController, with: .resetStack)
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
			AlertHelper.showAlert(title: String.error, detailText: String.signInFailed, actions: [AlertHelper.AlertAction(withTitle: String.ok)])
		} else if let authDataResult = authDataResult {
			authDataResult.user.getIDTokenResult { [weak self] tokenResult, error in
				self?.hideHUD()
				if let error = error {
					ALog.info("\(error.localizedDescription)")
					AlertHelper.showAlert(title: String.error, detailText: String.signInFailed, actions: [AlertHelper.AlertAction(withTitle: String.ok)])
					completion(false)
				} else if tokenResult?.token != nil {
					Keychain.userEmail = Auth.auth().currentUser?.email
					Keychain.authenticationToken = AuthenticaionToken(result: tokenResult)
					ALog.info("firebaseToken: \(tokenResult?.token ?? "")")
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
