import CareKitStore
import Firebase
import FirebaseAuth
import JGProgressHUD
import LocalAuthentication
import UIKit

class MasterCoordinator: Coordinable {
	let type: CoordinatorType = .masterCoordinator

	private var window: UIWindow
	internal var childCoordinators: [CoordinatorType: Coordinable]
	internal var navigationController: UINavigationController?
	internal let hud: JGProgressHUD = {
		let view = JGProgressHUD(style: .dark)
		view.vibrancyEnabled = true
		return view
	}()

	lazy var remoteConfigManager = RemoteConfigManager()
	lazy var context = LAContext()
	var signUpCompleted: Bool = false

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

	public func start() {
		if !UserDefaults.standard.hasRunOnce {
			DataContext.shared.clearAll()
			let firebaseAuth = Auth.auth()
			do {
				try firebaseAuth.signOut()
			} catch let signOutError {
				ALog.error("Error signing out:", error: signOutError)
			}
			UserDefaults.standard.hasRunOnce = true
			UserDefaults.standard.isCarePlanPopulated = false
		}
		if Auth.auth().currentUser == nil {
			goToAuth()
		} else {
			biometricsAuthentication()
		}
	}

	public func goToAuth(url: String = "") {
		removeCoordinator(ofType: .mainAppCoordinator)
		Keychain.clearKeychain()
		DataContext.shared.clearAll()
		let authCoordinator = AuthCoordinator(withParent: self, deepLink: url)
		addChild(coordinator: authCoordinator)
		window.rootViewController = authCoordinator.rootViewController
	}

	public func goToMainApp() {
		removeCoordinator(ofType: .authCoordinator)
		let mainAppCoordinator = MainAppCoordinator(with: self)
		addChild(coordinator: mainAppCoordinator)
		let rootViewController = mainAppCoordinator.rootViewController
		var transitionOptions = UIWindow.TransitionOptions()
		transitionOptions.direction = .fade
		window.setRootViewController(rootViewController, options: transitionOptions)
		window.rootViewController = rootViewController
		if let user = Auth.auth().currentUser {
			syncPatient(user: user) { result in
				if result {
					NotificationCenter.default.post(name: .patientDidSnychronize, object: nil)
				}
			}
		}
	}

	internal func biometricsAuthentication() {
		guard UserDefaults.standard.isBiometricsEnabled else {
			goToAuth()
			return
		}
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
						self?.goToMainApp()
					} else {
						self?.goToAuth()
					}
				}
			})
		}
	}

	internal func firebaseAuthentication(completion: @escaping (Bool) -> Void) {
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
			self?.signUpCompleted = true
			completion(true)
		})
	}

	func uploadPatient(patient: OCKPatient) {
		syncPatient(patient: patient) { result in
			if result == true {
				ALog.info("OK STATUS FOR PATIENT : 200")
			} else {
				AlertHelper.showAlert(title: Str.error, detailText: Str.createPatientFailed, actions: [AlertHelper.AlertAction(withTitle: Str.ok)])
			}
		}
	}

	func syncPatient(user: RemoteUser, completion: @escaping (Bool) -> Void) {
		CareManager.register(provider: AppDelegate.careManager.provider)
		AppDelegate.careManager.findOrCreate(user: user, completion: { [weak self] addResult in
			switch addResult {
			case .failure(let error):
				ALog.error("Unable to add Patient to store", error: error)
				completion(false)
			case .success(let patient):
				self?.syncPatient(patient: patient, completion: completion)
			}
		})
	}

	func syncPatient(patient: OCKPatient, completion: @escaping (Bool) -> Void) {
		CareManager.getCarePlan { carePlanResult in
			switch carePlanResult {
			case .failure(let error):
				ALog.error("Error Fetching care Plan \(error.localizedDescription)")
			case .success(let carePlan):
				if let serverPatient = carePlan.allPatients.first, let FHIRid = serverPatient.FHIRId, !FHIRid.isEmpty {
					let ockPatient = OCKPatient(patient: serverPatient)
					AppDelegate.careManager.insert(carePlansResponse: carePlan, for: ockPatient, completion: nil)
					completion(true)
				} else {
					CareManager.postPatient(patient: patient) { postPatientResult in
						switch postPatientResult {
						case .failure(let error):
							ALog.error("error creating \(error.localizedDescription)")
							completion(false)
						case .success(let vectorClock):
							ALog.info("vectorClock: \(vectorClock)")
							CareManager.getCarePlan { newCarePlanResult in
								switch newCarePlanResult {
								case .failure(let error):
									ALog.error("error creating \(error.localizedDescription)")
									completion(false)
								case .success(let newCarePlanResponse):
									if let serverPatient = carePlan.allPatients.first, let FHIRid = serverPatient.FHIRId, !FHIRid.isEmpty {
										let ockPatient = OCKPatient(patient: serverPatient)
										AppDelegate.careManager.insert(carePlansResponse: newCarePlanResponse, for: ockPatient, completion: nil)
									}
									completion(true)
								}
							}
						}
					}
				}
			}
		}
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
			try firebaseAuth.signOut()
			DataContext.shared.clearAll()
			UserDefaults.standard.removeBiometrics()
			try AppDelegate.careManager.resetAllContents()
			goToAuth()
		} catch let signOutError as NSError {
			ALog.error("Error signing out:", error: signOutError)
		}
	}

	func goToHealthKitAuthorization() {
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
				self?.goToMainApp()
			}
		}
	}
}
