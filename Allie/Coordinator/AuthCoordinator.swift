//
//  AuthCoordinator.swift
//  Allie
//

import AuthenticationServices
import CareKitStore
import CareModel
import Combine
import CryptoKit
import Firebase
import FirebaseAuth
import GoogleSignIn
import HealthKit
import KeychainAccess
import UIKit

@MainActor
class AuthCoordinator: BaseCoordinator {
	weak var parent: MainCoordinator?
	var currentNonce: String?
	var authorizationFlowType: AuthorizationFlowType = .signUp
	var alliePatient: CHPatient?

	override var rootViewController: UIViewController? {
		navigationController
	}

	init(parent: MainCoordinator?, deepLink: String?) {
		ALog.info("Auth Coordinator init")
		super.init(type: .authentication)
		navigationController = UINavigationController()
		self.parent = parent
		parent?.window.rootViewController = SplashViewController()

		if let link = deepLink {
			verifySendLink(link: link)
		} else {
			start()
		}
	}

	override func start() {
		ALog.info("Auth Coordinator start")
		gotoSignup()
	}

	func showHUD(title: String? = nil, message: String? = nil, animated: Bool = true) {
		parent?.showHUD(title: title, message: message, animated: animated)
	}

	func hideHUD(animated: Bool = true) {
		parent?.hideHUD(animated: animated)
	}

	func gotoSignup(authorizationFlowType type: AuthorizationFlowType = .signIn) {
		ALog.info("gotoSignup: \(type)")
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

		signupViewController.googleAuthorizationAction = { [weak self, weak signupViewController] in
			self?.signInWithGoogle(presentingViewController: signupViewController)
		}

		navigate(to: signupViewController, with: .resetStack)
	}

	func gotoLogin(authorizationFlowType type: AuthorizationFlowType = .signIn) {
		ALog.info("gotoLogin: \(type)")
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

		loginViewController.googleAuthorizationAction = { [weak self, weak loginViewController] in
			self?.signInWithGoogle(presentingViewController: loginViewController)
		}

		navigate(to: loginViewController, with: .push)
	}

	func gotoEmailSignup() {
		ALog.info("gotoEmailSignup")
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
				AlertHelper.showAlert(title: String.error, detailText: String.failedSendLink, actions: [AlertHelper.AlertAction(withTitle: String.ok)], from: self?.parent?.window.visibleViewController)
				return
			}

			self?.keychain.userEmail = email
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
		ALog.info("verifySendLink: \(link)")
		if let email = keychain.userEmail {
			showHUD()
			if Auth.auth().isSignIn(withEmailLink: link) {
				Auth.auth().signIn(withEmail: email, link: link) { [weak self] authResult, error in
					DispatchQueue.main.async { [weak self] in
						self?.hideHUD()
					}
					if error == nil {
						self?.getFirebaseAuthTokenResult(authDataResult: authResult, error: error, completion: { _ in
							DispatchQueue.main.async { [weak self] in
								if let authorizationFlowType = self?.authorizationFlowType, authorizationFlowType == .signIn {
									self?.healthKitManager.authorizeHealthKit { _, _ in
										DispatchQueue.main.async { [weak self] in
											self?.parent?.gotoMainApp()
										}
									}
								} else {
									self?.checkIfUserExists(email: email, user: authResult)
								}
							}
						})
					} else {
						DispatchQueue.main.async { [weak self] in
							AlertHelper.showAlert(title: error?.localizedDescription, detailText: String.signInFailed, actions: [AlertHelper.AlertAction(withTitle: String.ok)], from: self?.parent?.window.visibleViewController)
						}
					}
				}
			}
		} else {
			AlertHelper.showAlert(title: String.error, detailText: String.signInFailed, actions: [AlertHelper.AlertAction(withTitle: String.ok)], from: parent?.window.visibleViewController)
			start()
		}
	}

	func getPatient(email: String?, user: RemoteUser) {
		ALog.info("getPatient email \(String(describing: email)), remoteUser = \(user)")
		guard let user = Auth.auth().currentUser else {
			gotoSignup()
			return
		}
		showHUD()
		networkAPI.getCarePlan(option: .carePlan)
			.sink { [weak self] completion in
				if case .failure(let error) = completion {
					self?.hideHUD()
					ALog.error("Unable to fetch CarePlan: ", error: error)
					self?.gotoProfileSetupViewController(email: email, user: user)
				}
			} receiveValue: { [weak self] carePlan in
				self?.hideHUD()
				if let patient = carePlan.patients.active.first {
					self?.alliePatient = patient
					let ockPatient = OCKPatient(patient: patient)
					try? self?.careManager.resetAllContents()
					self?.careManager.process(patient: ockPatient) { patientResult in
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
			}.store(in: &cancellables)
	}

	func gotoProfileSetupViewController(email: String?, user: RemoteUser) {
		try? careManager.resetAllContents()
		if alliePatient == nil {
			alliePatient = CHPatient(user: user)
		}
		if let email = email {
			alliePatient?.profile.email = email
		}
		gotoProfileEntryViewController()
	}

	func gotoProfileEntryViewController(from screen: NavigationSourceType = .signUp) {
		let viewController = ProfileEntryViewController()
		if alliePatient == nil {
			alliePatient = CHPatient(user: Auth.auth().currentUser)
		}
		viewController.patient = alliePatient
		viewController.doneAction = { [weak self] in
			var patient = self?.alliePatient ?? CHPatient(user: Auth.auth().currentUser)
			patient?.name = viewController.name
			patient?.sex = viewController.sex
			patient?.updatedDate = Date()
			patient?.birthday = viewController.dateOfBirth
			patient?.profile.weightInPounds = viewController.weightInPounds
			patient?.profile.heightInInches = viewController.heightInInches
			self?.alliePatient = patient
			self?.createPatient()
		}
		navigate(to: viewController, with: .push)
	}

	func gotoHealthViewController(screenFlowType: ScreenFlowType) {
		let healthViewController = HealthViewController()
		healthViewController.screenFlowType = screenFlowType
		healthViewController.authorizationFlowType = authorizationFlowType

		healthViewController.activateAction = { [weak self] in
			//			self?.authorizeHKForUpload()
			self?.connectProvider()
		}

		navigate(to: healthViewController, with: .push)
	}

	func createPatient() {
		alliePatient?.profile.isSignUpCompleted = true
		careManager.patient = alliePatient
		let title = NSLocalizedString("CREATING_ACCOUNT", comment: "Creating Account")
		showHUD(title: title, message: nil, animated: true)
		Task.detached(priority: .userInitiated) { [weak self] in
			guard let strongSelf = self else {
				return
			}

			do {
				let carePlanResponse = try await strongSelf.networkAPI.post(patient: strongSelf.alliePatient!)
				if let patient = carePlanResponse.patients.active.first {
					await strongSelf.careManager.patient = patient
				}

				_ = await strongSelf.parent?.refreshRemoteConfig()
				await MainActor.run(body: {
					strongSelf.hideHUD()
					strongSelf.gotoHealthViewController(screenFlowType: .healthKit)
				})
			} catch {
				await MainActor.run(body: {
					let okAction = AlertHelper.AlertAction(withTitle: String.ok) {
						strongSelf.parent?.refreshRemoteConfig(completion: { _ in
							strongSelf.hideHUD()
						})
					}
					strongSelf.showAlert(title: "Unable to create Patient", detailText: error.localizedDescription, actions: [okAction])
				})
			}
		}
	}

	func connectProvider() {
		let connectProviderViewController = ConnectProviderViewController()
		connectProviderViewController.showProviderList = { [weak self] in
			self?.selectProvider()
		}
		navigate(to: connectProviderViewController, with: .push)
	}

	func selectProvider() {
		let selectProviderController = SelectProviderViewController(collectionViewLayout: SelectProviderViewController.layout)
		selectProviderController.doneAction = { [weak selectProviderController] _ in
			selectProviderController?.dismiss(animated: true, completion: nil)
		}
	}

	func authorizeHKForUpload() {
		healthKitManager.authorizeHealthKit { [weak self] authorized, error in
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
			DispatchQueue.main.async { [weak self] in
				self?.parent?.gotoMainApp()
			}
		}
	}

	func signInWithApple() {
		let request = createAuthorizationAppleIDRequest()
		let authorizationController = ASAuthorizationController(authorizationRequests: [request])
		authorizationController.delegate = self
		authorizationController.presentationContextProvider = self
		authorizationController.performRequests()
		ALog.info("Got in startSignInWithApple")
	}

	func signInWithGoogle(presentingViewController viewController: UIViewController?) {
		guard let clientId = FirebaseApp.app()?.options.clientID, let viewController = viewController else {
			return
		}
		let configuration = GIDConfiguration(clientID: clientId)
		GIDSignIn.sharedInstance.signIn(with: configuration, presenting: viewController) { user, error in
			if let error = error {
				ALog.error(error: error)
				return
			}

			guard let idToken = user?.authentication.idToken, let accessToken = user?.authentication.accessToken, error == nil else {
				ALog.error(error: error)
				return
			}

			let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
			Auth.auth().signIn(with: credential) { [weak self] authResult, error in
				self?.getFirebaseAuthTokenResult(authDataResult: authResult, error: error, completion: { [weak self] _ in
					if let authUser = authResult?.user {
						var alliePatient = CHPatient(user: authUser)
						var name = PersonNameComponents()
						if let givenName = user?.profile?.givenName {
							name.givenName = givenName
						}
						if let familyName = user?.profile?.familyName {
							name.familyName = familyName
						}
						if alliePatient?.profile.email == nil {
							alliePatient?.profile.email = user?.profile?.email
						}
						self?.alliePatient = alliePatient
					}
					self?.checkIfUserExists(email: user?.profile?.email, user: authResult)
				})
			}
		}
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
			AlertHelper.showAlert(title: String.error, detailText: String.signInFailed, actions: [AlertHelper.AlertAction(withTitle: String.ok)], from: parent?.window.visibleViewController)
		} else if let authDataResult = authDataResult {
			authDataResult.user.getIDTokenResult { [weak self] tokenResult, error in
				self?.hideHUD()
				if let error = error {
					ALog.info("\(error.localizedDescription)")
					AlertHelper.showAlert(title: String.error, detailText: String.signInFailed, actions: [AlertHelper.AlertAction(withTitle: String.ok)], from: self?.parent?.window.visibleViewController)
					completion(false)
				} else if tokenResult?.token != nil {
					self?.keychain.userEmail = Auth.auth().currentUser?.email
					self?.keychain.authenticationToken = AuthenticationToken(result: tokenResult)
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

extension AuthCoordinator: ASAuthorizationControllerDelegate {
	func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
		ALog.trace("Hello Apple")

		if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
			guard let nonce = currentNonce else {
				ALog.error("Invalid state: A login callback was received, but no login request was sent.")
				return
			}
			guard let appleIDToken = appleIDCredential.identityToken else {
				ALog.error("Unable to fetch identity token")
				return
			}
			guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
				ALog.error("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
				return
			}
			let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
			Auth.auth().signIn(with: credential) { [weak self] tokenAuthResult, error in
				self?.getFirebaseAuthTokenResult(authDataResult: tokenAuthResult, error: error, completion: { [weak self] _ in
					if let user = tokenAuthResult?.user {
						var alliePatient = CHPatient(user: user)
						if let name = appleIDCredential.fullName {
							alliePatient?.name = name
						}
						if alliePatient?.profile.email == nil {
							alliePatient?.profile.email = appleIDCredential.email
						}
						self?.alliePatient = alliePatient
					}
					self?.checkIfUserExists(email: appleIDCredential.email, user: tokenAuthResult)
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
