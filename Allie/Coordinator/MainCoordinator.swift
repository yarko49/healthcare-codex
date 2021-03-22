//
//  MainCoordinator.swift
//  Allie
//

import CareKitStore
import Combine
import Firebase
import FirebaseAuth
import JGProgressHUD
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

	lazy var remoteConfigManager = RemoteConfigManager()
	lazy var context = LAContext()

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
			UserDefaults.resetStandardUserDefaults()
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
		window.rootViewController = rootViewController
		if let user = Auth.auth().currentUser {
			registerProvider(user: user) { result in
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
						self?.gotoMainApp()
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
			self?.careManager.patient?.isSignUpCompleted = true
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

	func registerProvider(user: RemoteUser, completion: @escaping (Bool) -> Void) {
		CareManager.register(provider: AppDelegate.careManager.provider)
			.replaceError(with: false)
			.sink { value in
				ALog.info("Register Provider result = \(value)")
				AppDelegate.careManager.findPatient(identifier: user.uid, completion: { findResult in
					switch findResult {
					case .failure(let error):
						ALog.error("Unable to add Patient to store", error: error)
					case .success(let patient):
						AppDelegate.careManager.patient = patient
					}
					completion(true)
				})
			}.store(in: &cancellables)
	}

	func syncPatient(patient: OCKPatient, completion: @escaping (Bool) -> Void) {
		CareManager.getCarePlan { carePlanResult in
			switch carePlanResult {
			case .failure(let error):
				ALog.error("Error Fetching care Plan \(error.localizedDescription)")
			case .success(let carePlan):
				if let serverPatient = carePlan.allPatients.first, let FHIRid = serverPatient.FHIRId, !FHIRid.isEmpty {
					AppDelegate.careManager.insert(carePlansResponse: carePlan, completion: nil)
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
										AppDelegate.careManager.insert(carePlansResponse: newCarePlanResponse, completion: nil)
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

	/* URLSession.shared.dataTaskPublisher(for: url)
	 .flatMap { data, response in
	     URLSession.shared.dataTaskPublisher(for: anotherURL)
	 }
	 .flatMap { data, response in
	     URLSession.shared.dataTaskPublisher(for: oneMoreURL)
	 }
	 .sink(receiveCompletion: { ... },
	       receiveValue: { ... })
	  */

	func syncPatient1(patient: OCKPatient, completion: @escaping (Bool) -> Void) {
		CareManager.getCarePlan { carePlanResult in
			switch carePlanResult {
			case .failure(let error):
				ALog.error("Error Fetching care Plan \(error.localizedDescription)")
			case .success(let carePlan):
				if let serverPatient = carePlan.allPatients.first, let FHIRid = serverPatient.FHIRId, !FHIRid.isEmpty {
					AppDelegate.careManager.insert(carePlansResponse: carePlan, completion: nil)
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
										AppDelegate.careManager.insert(carePlansResponse: newCarePlanResponse, completion: nil)
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
			UserDefaults.resetStandardUserDefaults()
			try AppDelegate.careManager.resetAllContents()
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
}
