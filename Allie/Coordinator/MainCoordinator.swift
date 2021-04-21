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

class MainCoordinator: Coordinable {
	let type: CoordinatorType = .mainCoordinator
	var cancellables: Set<AnyCancellable> = []

	private var window: UIWindow
	var childCoordinators: [CoordinatorType: Coordinable]
	var navigationController: UINavigationController?

	let hud: JGProgressHUD = {
		let view = JGProgressHUD(style: .dark)
		view.vibrancyEnabled = true
		return view
	}()

	lazy var keychain = KeychainAccess.Keychain(server: AppConfig.apiBaseHost, protocolType: .https, accessGroup: AppConfig.keychainAccessGroup, authenticationType: .default)
	lazy var remoteConfigManager = RemoteConfigManager()
	lazy var context = LAContext()
	var didRegisterOrgnization: Bool = false

	public var rootViewController: UIViewController? {
		navigationController
	}

	func showHUD(animated: Bool = true) {
		hud.show(in: window, animated: animated)
	}

	func hideHUD(animated: Bool = true) {
		hud.dismiss(animated: animated)
	}

	init(in window: UIWindow) {
		self.childCoordinators = [:]
		self.window = window
		self.window.rootViewController = rootViewController
		self.window.makeKeyAndVisible()
	}

	func start() {
		if !UserDefaults.standard.hasRunOnce {
			UserDefaults.resetStandardUserDefaults()
			let firebaseAuth = Auth.auth()
			do {
				try firebaseAuth.signOut()
			} catch let signOutError {
				ALog.error("Error signing out:", error: signOutError)
			}
			UserDefaults.standard.hasRunOnce = true
			UserDefaults.standard.isCarePlanPopulated = false
			Keychain.clearKeychain()
		}
		if Auth.auth().currentUser == nil {
			goToAuth()
		} else {
			biometricsAuthentication()
		}
	}

	func goToAuth(url: String? = nil) {
		removeCoordinator(ofType: .appCoordinator)
		Keychain.clearKeychain()
		UserDefaults.resetStandardUserDefaults()
		let authCoordinator = AuthCoordinator(parentCoordinator: self, deepLink: url)
		addChild(coordinator: authCoordinator)
		window.rootViewController = authCoordinator.rootViewController
	}

	public func gotoMainApp() {
		removeCoordinator(ofType: .authCoordinator)
		let appCoordinator = AppCoordinator(with: self)
		addChild(coordinator: appCoordinator)
		let rootViewController = appCoordinator.rootViewController
		var transitionOptions = UIWindow.TransitionOptions()
		transitionOptions.direction = .fade
		window.setRootViewController(rootViewController, options: transitionOptions)
	}

	func createPatientIfNeeded() {
		if let patient = careManager.patient, patient.profile.fhirId == nil {
			APIClient.client.postPatient(patient: patient)
				.receive(on: DispatchQueue.main)
				.sink { [weak self] completion in
					switch completion {
					case .failure(let error):
						ALog.error("\(error.localizedDescription)")
						AlertHelper.showAlert(title: Str.error, detailText: Str.createPatientFailed, actions: [AlertHelper.AlertAction(withTitle: Str.ok)])
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
		let reason = Str.authWithBiometrics
		context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, _ in
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

	func registerServices() {
		if careManager.patient == nil {
			careManager.loadPatient { [weak self] result in
				switch result {
				case .failure(let error):
					ALog.error("\(error.localizedDescription)")
				case .success:
					AppDelegate.registerServices(patient: self?.careManager.patient)
				}
			}
		} else {
			AppDelegate.registerServices(patient: careManager.patient)
		}
	}

	func firebaseAuthentication(completion: @escaping (Bool) -> Void) {
		Auth.auth().currentUser?.getIDTokenResult(completion: { [weak self] tokenResult, error in
			guard error == nil else {
				ALog.error("Error signing out:", error: error)
				completion(false)
				return
			}
			guard let firebaseToken = tokenResult?.token else {
				completion(false)
				return
			}
			Keychain.authToken = firebaseToken
			self?.refreshRemoteConfig { _ in
				completion(true)
			}
		})
	}

	func uploadPatient(patient: AlliePatient) {
		APIClient.client.postPatient(patient: patient)
			.receive(on: DispatchQueue.main)
			.sink { completion in
				switch completion {
				case .failure(let error):
					ALog.error("\(error.localizedDescription)")
					AlertHelper.showAlert(title: Str.error, detailText: Str.createPatientFailed, actions: [AlertHelper.AlertAction(withTitle: Str.ok)])
				case .finished:
					break
				}
			} receiveValue: { _ in
				ALog.info("OK STATUS FOR PATIENT : 200")
			}.store(in: &cancellables)
	}

	func syncHealthKitData() {
		HealthKitSyncManager.syncDataBackground(initialUpload: false, chunkSize: UserDefaults.standard.healthKitUploadChunkSize) { uploaded, total in
			ALog.info("HealthKit data upload progress = \(uploaded), total: \(total)")
		} completion: { success in
			if success == false {
				// show alert
			}
		}
	}

	func logout() {
		let firebaseAuth = Auth.auth()
		do {
			if let uid = Auth.auth().currentUser?.uid {
				Keychain.delete(valueForKey: uid)
			}
			try firebaseAuth.signOut()
			UserDefaults.resetStandardUserDefaults()
			try AppDelegate.careManager.resetAllContents()
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
		remoteConfigManager.refresh()
			.sink { refreshResult in
				ALog.info("Did finsihed remote configuration synchronization with result = \(refreshResult)")
				CareManager.register(provider: self.remoteConfigManager.healthCareOrganization)
					.sink { registrationResult in
						ALog.info("Did finish registering organization \(registrationResult)")
						completion?(registrationResult)
					}.store(in: &self.cancellables)
			}.store(in: &cancellables)
	}
}
