//
//  MainCoordinator.swift
//  Allie
//

import CareKitStore
import Combine
import CoreData
import Firebase
import FirebaseAuth
import JGProgressHUD
import KeychainAccess
import UIKit

class MainCoordinator: BaseCoordinator {
	private(set) var window: UIWindow

	let hud: JGProgressHUD = {
		let view = JGProgressHUD(style: .dark)
		view.vibrancyEnabled = true
		return view
	}()

	@Injected(\.remoteConfig) var remoteConfig: RemoteConfigManager

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
		ALog.info("MainCoordinator start")
		super.start()
		if Auth.auth().currentUser == nil {
			ALog.info("MainCoordinator start currentUser == nil")
			goToAuth()
		} else {
			firebaseAuthentication(completion: { [weak self] success in
				DispatchQueue.main.async {
					if success {
						self?.createPatientIfNeeded()
					} else {
						self?.goToAuth()
					}
				}
			})
		}
	}

	func goToAuth(url: String? = nil) {
		ALog.info("goToAuth: \(String(describing: url))")
		removeCoordinator(ofType: .application)
		let authCoordinator = AuthCoordinator(parent: self, deepLink: url)
		addChild(coordinator: authCoordinator)
		window.rootViewController = authCoordinator.rootViewController
	}

	public func gotoMainApp() {
		showHUD()
		networkAPI.getOrganizations()
			.receive(on: DispatchQueue.main)
			.sink { [weak self] organizations in
				self?.hideHUD()
				self?.showMainApp(organizations: organizations)
			}.store(in: &cancellables)
	}

	func showMainApp(organizations: CHOrganizations) {
		removeCoordinator(ofType: .application)
		let appCoordinator = AppCoordinator(parent: self, organizations: organizations)
		addChild(coordinator: appCoordinator)
		let rootViewController = appCoordinator.rootViewController
		var transitionOptions = UIWindow.TransitionOptions()
		transitionOptions.direction = .fade
		window.setRootViewController(rootViewController, options: transitionOptions)
		AppDelegate.registerServices(patient: careManager.patient)
		#if !targetEnvironment(simulator)
		AppDelegate.appDelegate?.registerForPushNotifications(application: UIApplication.shared)
		#endif
	}

	func showMessagesTab() {
		let appController = self[.application] as? AppCoordinator
		appController?.tabBarController?.selectedIndex = 2
	}

	func updateBadges(count: Int) {
		let appController = self[.application] as? AppCoordinator
		let tabbarItem = appController?.tabBarController?.tabBar.items?[2]
		tabbarItem?.badgeColor = .systemRed
		// swiftlint:disable:next empty_count
		tabbarItem?.badgeValue = count > 0 ? "\(count)" : nil
	}

	func updateZendeskBadges(count: Int) {
		let appController = self[.application] as? AppCoordinator
		let tabbarItem = appController?.tabBarController?.tabBar.items?[3]
		tabbarItem?.badgeColor = .systemRed
		// swiftlint:disable:next empty_count
		tabbarItem?.badgeValue = count > 0 ? "\(count)" : nil
	}

	func createPatientIfNeeded() {
		if let patient = careManager.patient, patient.profile.fhirId == nil {
			networkAPI.post(patient: patient)
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

	func firebaseAuthentication(completion: @escaping (Bool) -> Void) {
		Auth.auth().currentUser?.getIDTokenResult(completion: { [weak self] tokenResult, error in
			guard error == nil else {
				ALog.error("Error signing out:", error: error)
				completion(false)
				return
			}
			guard tokenResult?.token != nil else {
				completion(false)
				return
			}
			if let userId = Auth.auth().currentUser?.uid {
				_ = self?.resetDataIfNeeded(newPatientId: userId)
			}
			if let token = AuthenticationToken(result: tokenResult) {
				self?.keychain.authenticationToken = token
			}
			completion(true)
		})
	}

	func syncHealthKitData() {
		let lastUploadDate = UserDefaults.standard.lastObervationUploadDate
		let endDate = Date()
		healthKitManager.syncData(startDate: lastUploadDate, endDate: endDate, options: []) { success in
			if success {
				UserDefaults.standard.lastObervationUploadDate = endDate
			}
		}
	}

	func logout() {
		resetAll()
		goToAuth()
	}

	func gotoHealthKitAuthorization() {
		healthKitManager.authorizeHealthKit { [weak self] authorized, error in
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

	func refreshRemoteConfig(completion: AllieBoolActionHandler?) {
		remoteConfig.refresh()
			.receive(on: DispatchQueue.main)
			.sink { [weak self] refreshResult in
				ALog.info("Did finsihed remote configuration synchronization with result = \(refreshResult)")
				DispatchQueue.main.async {
					self?.showUpgradeAlertIfNeede()
				}
				completion?(refreshResult)
			}.store(in: &cancellables)
	}

	func showUpgradeAlertIfNeede() {
		let current = ApplicationVersion.current!
		let supportedVersion = remoteConfig.minimumSupportedVersion
		guard supportedVersion.version > current else {
			return
		}
		let title = NSLocalizedString("UPDATE_REQUIRED", comment: "Update Required")
		let controller = UIAlertController(title: title, message: supportedVersion.message, preferredStyle: .alert)
		let action = UIAlertAction(title: "Go to store", style: .default) { _ in
			if let url = URL(string: "https://apps.apple.com/us/app/allie-your-wellness-app/id1553634187") {
				UIApplication.shared.open(url, options: [:]) { success in
					ALog.info("Did open store \(success)")
				}
			}
		}
		controller.addAction(action)
		window.rootViewController?.showDetailViewController(controller, sender: self)
	}
}
