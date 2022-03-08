//
//  MainCoordinator.swift
//  Allie
//

import CareKitStore
import CodexFoundation
import CodexModel
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
	@KeychainStorage(Keychain.Keys.organizations)
	var organizations: CMOrganizations?

	override public var rootViewController: UIViewController? {
		navigationController
	}

	@MainActor
	func showHUD(title: String? = nil, message: String? = nil, animated: Bool = true) {
		hud.textLabel.text = title
		hud.detailTextLabel.text = message
		hud.show(in: window, animated: animated)
	}

	@MainActor
	func hideHUD(animated: Bool = true) {
		hud.dismiss(animated: animated)
	}

	@MainActor
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

	@MainActor
	override func start() {
		ALog.info("MainCoordinator start")
		super.start()
		if Auth.auth().currentUser == nil {
			ALog.info("MainCoordinator start currentUser == nil")
			goToAuth()
		} else {
			Task { [weak self] in
				guard let strongSelf = self else {
					return
				}
				let success = await strongSelf.firebaseAuthentication()
				if success {
					await strongSelf.createPatientIfNeeded()
				} else {
					strongSelf.goToAuth()
				}
			}
		}
	}

	@MainActor
	func goToAuth(url: String? = nil) {
		ALog.info("goToAuth: \(String(describing: url))")
		removeCoordinator(ofType: .application)
		let authCoordinator = AuthCoordinator(parent: self, deepLink: url)
		addChild(coordinator: authCoordinator)
		window.rootViewController = authCoordinator.rootViewController
	}

	@MainActor
	public func gotoMainApp() {
		showHUD()
		Task.detached(priority: .userInitiated) { [weak self] in
			guard let strongSelf = self else {
				return
			}
			do {
				let organizations = try await strongSelf.networkAPI.getOrganizations()
				await MainActor.run(body: {
					strongSelf.organizations = organizations
				})
			} catch {
				ALog.error("Error Getting Organizations", error: error)
			}

			await MainActor.run(body: { [weak self] in
				self?.hideHUD()
				self?.showMainApp()
			})
		}
	}

	@MainActor
	func showMainApp() {
		removeCoordinator(ofType: .application)
		let appCoordinator = AppCoordinator(parent: self)
		addChild(coordinator: appCoordinator)
		let rootViewController = appCoordinator.rootViewController
		var transitionOptions = UIWindow.TransitionOptions()
		transitionOptions.direction = .fade
		window.setRootViewController(rootViewController, options: transitionOptions)
		AppDelegate.registerServices(patient: careManager.patient)
		let zendCount = UserDefaults.zendeskChatNotificationCount
		updateZendeskBadges(count: zendCount)
		#if !targetEnvironment(simulator)
		AppDelegate.appDelegate?.registerForPushNotifications(application: UIApplication.shared)
		#endif
	}

	@MainActor
	func showMessagesTab() {
		let appController = self[.application] as? AppCoordinator
		appController?.tabBarController?.selectedIndex = 2
	}

	@MainActor
	func updateZendeskBadges(count: Int) {
		let appController = self[.application] as? AppCoordinator
		let tabbarItem = appController?.tabBarController?.tabBar.items?[3]
		tabbarItem?.badgeColor = .systemRed
		// swiftlint:disable:next empty_count
		tabbarItem?.badgeValue = count > 0 ? "\(count)" : nil
	}

	func createPatientIfNeeded() async {
		if let patient = careManager.patient, patient.profile.fhirId == nil {
			do {
				_ = try await networkAPI.post(patient: patient)
			} catch {
				ALog.error("\(error.localizedDescription)")
				await MainActor.run { [weak self] in
					AlertHelper.showAlert(title: String.error, detailText: String.createPatientFailed, actions: [AlertHelper.AlertAction(withTitle: String.ok)], from: self?.window.visibleViewController)
				}
			}

			await MainActor.run { [weak self] in
				self?.gotoMainApp()
			}
		} else {
			gotoMainApp()
		}
	}

	func firebaseAuthentication() async -> Bool {
		do {
			let tokenResult = try await Auth.auth().currentUser?.getIDTokenResult()
			guard tokenResult?.token != nil else {
				return false
			}
			if let userId = Auth.auth().currentUser?.uid {
				_ = resetDataIfNeeded(newPatientId: userId)
			}
			if let token = AuthenticationToken(result: tokenResult) {
				keychain.authenticationToken = token
			}
			return true
		} catch {
			ALog.error("Error getting token:", error: error)
			return false
		}
	}

	func syncHealthKitData() {
		let lastUploadDate = UserDefaults.lastObervationUploadDate
		let endDate = Date()
		healthKitManager.syncData(startDate: lastUploadDate, endDate: endDate, options: []) { success in
			if success {
				UserDefaults.lastObervationUploadDate = endDate
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
			DispatchQueue.main.async { [weak self] in
				self?.gotoMainApp()
			}
		}
	}

	func refreshRemoteConfig(completion: AllieBoolActionHandler?) {
		remoteConfig.refresh()
			.receive(on: DispatchQueue.main)
			.sink { [weak self] refreshResult in
				ALog.info("Did finsihed remote configuration synchronization with result = \(refreshResult)")
				DispatchQueue.main.async { [weak self] in
					self?.showUpgradeAlertIfNeede()
				}
				completion?(refreshResult)
			}.store(in: &cancellables)
	}

	func refreshRemoteConfig() async -> Bool {
		let result = await remoteConfig.refresh()
		DispatchQueue.main.async { [weak self] in
			self?.showUpgradeAlertIfNeede()
		}
		return result
	}

	@MainActor
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
		window.visibleViewController?.showDetailViewController(controller, sender: self)
	}
}
