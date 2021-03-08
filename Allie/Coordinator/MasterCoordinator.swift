import CareKitStore
import Firebase
import FirebaseAuth
import JGProgressHUD
import LocalAuthentication
import UIKit

class MasterCoordinator: Coordinable {
	private var window: UIWindow
	internal var childCoordinators: [CoordinatorType: Coordinable]
	internal var navigationController: UINavigationController?
	internal let hud: JGProgressHUD = {
		let view = JGProgressHUD(style: .dark)
		view.vibrancyEnabled = true
		return view
	}()

	let remoteConfigManager = RemoteConfigManager()
	var context = LAContext()
	var error: NSError?

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
		showMockSplashScreen()
	}

	internal func showMockSplashScreen() {
		let mockSplashViewController = SplashViewController()
		window.rootViewController = mockSplashViewController
		guard Auth.auth().currentUser != nil else {
			goToAuth()
			return
		}
		biometricsAuthentication()
	}

	public func goToAuth(url: String = "") {
		removeChild(.mainAppCoordinator)
		DataContext.shared.clearAll()
		let authCoordinator = AuthCoordinator(withParent: self, deepLink: url)
		addChild(coordinator: authCoordinator, with: .authCoordinator)
		window.rootViewController = authCoordinator.rootViewController
	}

	public func goToMainApp(showingLoader: Bool = true) {
		removeChild(.authCoordinator)
		let mainAppCoordinator = MainAppCoordinator(with: self)
		addChild(coordinator: mainAppCoordinator, with: .mainAppCoordinator)
		let rootViewController = mainAppCoordinator.rootViewController
		window.rootViewController = rootViewController
		if let user = Auth.auth().currentUser {
			if showingLoader {
				hud.show(in: rootViewController?.view ?? AppDelegate.primaryWindow)
			}

			syncPatient(user: user) { [weak self] _ in
				if showingLoader {
					DispatchQueue.main.async {
						self?.hud.dismiss()
					}
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
		Auth.auth().tenantID = AppConfig.tenantID
		Auth.auth().currentUser?.getIDTokenResult(completion: { tokenResult, error in
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
			DataContext.shared.signUpCompleted = true
			completion(true)
		})
	}

	func syncPatient(user: RemoteUser, completion: @escaping (Bool) -> Void) {
		CareManager.register(provider: AppDelegate.careManager.provider)
		AppDelegate.careManager.findOrCreate(user: user, completion: { addResult in
			switch addResult {
			case .failure(let error):
				ALog.error("Unable to add Patient to store", error: error)
				completion(false)
			case .success(let patient):
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
		})
	}

	func syncHealthKitData() {
		HealthKitSyncManager.syncDataBackground(initialUpload: false, chunkSize: UserDefaults.standard.healthKikUploadChunkSize) { uploaded, total in
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
}
