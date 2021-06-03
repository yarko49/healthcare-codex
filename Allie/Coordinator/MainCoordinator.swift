//
//  MainCoordinator.swift
//  Allie
//

import CareKitStore
import Combine
import Firebase
import FirebaseAuth
import JGProgressHUD
import KeychainAccess
import LocalAuthentication
import UIKit

class MainCoordinator: BaseCoordinator {
	private(set) var window: UIWindow

	let hud: JGProgressHUD = {
		let view = JGProgressHUD(style: .dark)
		view.vibrancyEnabled = true
		return view
	}()

	override public var rootViewController: UIViewController? {
		navigationController
	}

	func showHUD(title: String? = nil, message: String? = nil, animated: Bool = true) {
		DispatchQueue.main.async { [weak self] in
			guard let strongSelf = self else {
				return
			}
			strongSelf.hud.textLabel.text = title
			strongSelf.hud.detailTextLabel.text = message
			strongSelf.hud.show(in: strongSelf.window, animated: animated)
		}
	}

	func hideHUD(animated: Bool = true) {
		DispatchQueue.main.async { [weak self] in
			self?.hud.dismiss(animated: animated)
		}
	}

	init(window: UIWindow) {
		self.window = window
		super.init(type: .main)
		let navController = UINavigationController(rootViewController: SplashViewController())
		navController.setNavigationBarHidden(true, animated: false)
		self.navigationController = navController
		self.window.rootViewController = rootViewController
		self.window.makeKeyAndVisible()

		NotificationCenter.default.publisher(for: .applicationDidLogout)
			.sink { [weak self] _ in
				self?.logout()
			}.store(in: &cancellables)
	}

	override func start() {
		super.start()
		if !UserDefaults.standard.hasRunOnce {
			UserDefaults.resetStandardUserDefaults()
			let firebaseAuth = Auth.auth()
			do {
				try firebaseAuth.signOut()
			} catch let signOutError {
				ALog.error("Error signing out:", error: signOutError)
			}
			UserDefaults.standard.hasRunOnce = true
			Keychain.clearKeychain()
		}
		if Auth.auth().currentUser == nil {
			goToAuth()
		} else {
			biometricsAuthentication()
		}
	}

	func goToAuth(url: String? = nil) {
		removeCoordinator(ofType: .application)
		Keychain.clearKeychain()
		UserDefaults.resetStandardUserDefaults()
		let authCoordinator = AuthCoordinator(parent: self, deepLink: url)
		addChild(coordinator: authCoordinator)
		window.rootViewController = authCoordinator.rootViewController
	}

	public func gotoMainApp() {
		removeCoordinator(ofType: .application)
		let appCoordinator = AppCoordinator(parent: self)
		addChild(coordinator: appCoordinator)
		let rootViewController = appCoordinator.rootViewController
		var transitionOptions = UIWindow.TransitionOptions()
		transitionOptions.direction = .fade
		window.setRootViewController(rootViewController, options: transitionOptions)
	}

	func createPatientIfNeeded() {
		if let patient = CareManager.shared.patient, patient.profile.fhirId == nil {
			APIClient.shared.post(patient: patient)
				.receive(on: DispatchQueue.main)
				.sink { [weak self] completion in
					switch completion {
					case .failure(let error):
						ALog.error("\(error.localizedDescription)")
						AlertHelper.showAlert(title: String.error, detailText: String.createPatientFailed, actions: [AlertHelper.AlertAction(withTitle: String.ok)])
					case .finished:
						break
					}
					self?.gotoMainApp()
				} receiveValue: { _ in
					ALog.info("OK STATUS FOR PATIENT : 200")
				}.store(in: &cancellables)
		} else {
			gotoMainApp()
		}
	}

	func biometricsAuthentication() {
		guard UserDefaults.standard.isBiometricsEnabled else {
			goToAuth()
			return
		}
		#if targetEnvironment(simulator)
		firebaseAuthentication(completion: { [weak self] success in
			DispatchQueue.main.async {
				if success {
					self?.createPatientIfNeeded()
				} else {
					self?.goToAuth()
				}
			}
		})
		#else
		let reason = String.authWithBiometrics
		authenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, _ in
			guard success else {
				DispatchQueue.main.async {
					self?.goToAuth()
				}
				return
			}
			self?.firebaseAuthentication(completion: { success in
				DispatchQueue.main.async {
					if success {
						self?.createPatientIfNeeded()
					} else {
						self?.goToAuth()
					}
				}
			})
		}
		#endif
	}

	func firebaseAuthentication(completion: @escaping (Bool) -> Void) {
		Auth.auth().currentUser?.getIDTokenResult(completion: { tokenResult, error in
			guard error == nil else {
				ALog.error("Error signing out:", error: error)
				completion(false)
				return
			}
			guard tokenResult?.token != nil else {
				completion(false)
				return
			}
			if let token = AuthenticaionToken(result: tokenResult) {
				Keychain.authenticationToken = token
			}
			completion(true)
		})
	}

	func uploadPatient(patient: AlliePatient) {
		APIClient.shared.post(patient: patient)
			.receive(on: DispatchQueue.main)
			.sink { completion in
				switch completion {
				case .failure(let error):
					ALog.error("\(error.localizedDescription)")
					AlertHelper.showAlert(title: String.error, detailText: String.createPatientFailed, actions: [AlertHelper.AlertAction(withTitle: String.ok)])
				case .finished:
					break
				}
			} receiveValue: { _ in
				ALog.info("OK STATUS FOR PATIENT : 200")
			}.store(in: &cancellables)
	}

	func syncHealthKitData() {
		let lastUploadDate = UserDefaults.standard.lastObervationUploadDate
		let endDate = Date()
		HealthKitManager.shared.syncData(startDate: lastUploadDate, endDate: endDate, options: []) { success in
			if success {
				UserDefaults.standard.lastObervationUploadDate = endDate
			}
		}
	}

	func logout() {
		let firebaseAuth = Auth.auth()
		do {
			try firebaseAuth.signOut()
			UserDefaults.standard.resetUserDefaults()
			CareManager.shared.reset()
			Keychain.clearKeychain()
			goToAuth()
		} catch let signOutError as NSError {
			ALog.error("Error signing out:", error: signOutError)
		}
	}

	func gotoHealthKitAuthorization() {
		HealthKitManager.shared.authorizeHealthKit { [weak self] authorized, error in
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
				self?.gotoMainApp()
			}
		}
	}

	func refreshRemoteConfig(completion: Coordinable.BoolActionHandler?) {
		RemoteConfigManager.shared.refresh()
			.sink { refreshResult in
				ALog.info("Did finsihed remote configuration synchronization with result = \(refreshResult)")
				let organization = Organization(id: RemoteConfigManager.shared.healthCareOrganization, name: "Default Organization", image: nil, info: nil)
				CareManager.register(organization: organization)
					.subscribe(on: DispatchQueue.main)
					.sink { registrationResult in
						ALog.info("Did finish registering organization \(registrationResult)")
						completion?(registrationResult)
					}.store(in: &self.cancellables)
			}.store(in: &cancellables)
	}
}
