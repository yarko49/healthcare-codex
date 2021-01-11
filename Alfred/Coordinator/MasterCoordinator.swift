import Firebase
import FirebaseAuth
import LocalAuthentication
import UIKit

class MasterCoordinator: Coordinator {
	private var window: UIWindow
	internal var childCoordinators: [CoordinatorKey: Coordinator]
	internal var navigationController: UINavigationController?

	var context = LAContext()
	var error: NSError?

	public var rootViewController: UIViewController? {
		navigationController
	}

	var hud: HUDView?

	func showHUD(animated: Bool = true) {
		guard hud == nil else {
			return
		}
		let title = NSLocalizedString("LOADING_DOTS", comment: "Loading...")
		hud = HUDView.show(presentingViewController: window.rootViewController, title: title, animated: animated)
	}

	func hideHUD(animated: Bool = true) {
		hud?.dismiss(animated: true, completion: nil)
		hud = nil
	}

	init(in window: UIWindow) {
		self.childCoordinators = [:]
		self.window = window
		self.window.rootViewController = rootViewController
		self.window.makeKeyAndVisible()
	}

	public func start() {
		NotificationCenter.default.addObserver(self, selector: #selector(handleLogout(_:)), name: .applicationDidLogout, object: nil)
		if !DataContext.shared.hasRunOnce {
			DataContext.shared.clearAll()
			let firebaseAuth = Auth.auth()
			do {
				try firebaseAuth.signOut()
			} catch let signOutError as NSError {
				ALog.error("Error signing out: \(signOutError.localizedDescription)")
			}
			DataContext.shared.hasRunOnce = true
		}
		showMockSplashScreen()
	}

	internal func showMockSplashScreen() {
		let mockSplashViewController = MockSplashViewController()
		window.rootViewController = mockSplashViewController

		if Auth.auth().currentUser == nil {
			goToAuth()
		} else {
			if DataContext.shared.isBiometricsEnabled {
				biometricsAuthentication { completion in
					if completion {
						Auth.auth().tenantID = AppConfig.tenantID
						Auth.auth().currentUser?.getIDToken(completion: { firebaseToken, error in
							if let error = error {
								ALog.error("Error signing out: \(error.localizedDescription)")
								self.goToAuth()
							} else {
								if let firebaseToken = firebaseToken {
									DataContext.shared.authToken = firebaseToken
									guard let user = Auth.auth().currentUser else {
										self.goToAuth()
										return
									}
									DataContext.shared.searchPatient(user: user) { [weak self] success in
										if success {
											DataContext.shared.identifyCrashlytics()
											DataContext.shared.getProfileAPI { [weak self] result in
												if result {
													self?.syncHKData()
												} else {
													self?.goToAuth()
												}
											}
										} else {
											self?.goToAuth()
										}
									}
								} else {
									self.goToAuth()
								}
							}
						})
					} else {
						DispatchQueue.main.async {
							self.goToAuth()
						}
					}
				}
			} else {
				goToAuth()
			}
		}
	}

	internal func biometricsAuthentication(completion: @escaping (Bool) -> Void) {
		let reason = Str.authWithBiometrics
		context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, _ in
			completion(success)
		}
	}

	internal func syncHKData() {
		var loadingShouldAppear = true
		let hkDataUploadViewController = HKDataUploadViewController()
		SyncManager.shared.syncData(initialUpload: false, chunkSize: 4500) { [weak self] uploaded, total in
			if total > 500, loadingShouldAppear {
				loadingShouldAppear = false
				self?.window.rootViewController = hkDataUploadViewController
			} else if total > 500 {
				hkDataUploadViewController.progress = uploaded
				hkDataUploadViewController.maxProgress = total
			}
		} completion: { [weak self] success in
			if success {
				self?.goToMainApp()
			} else {
				AlertHelper.showAlert(title: Str.error, detailText: Str.importHealthDataFailed, actions: [])
				self?.goToMainApp()
			}
		}
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
		window.rootViewController = mainAppCoordinator.rootViewController
	}

	@objc func handleLogout(_ sender: Notification) {
		let firebaseAuth = Auth.auth()
		do {
			try firebaseAuth.signOut()
		} catch let signOutError as NSError {
			ALog.error("Error signing out: \(signOutError.localizedDescription)")
		}
		DispatchQueue.main.async { [weak self] in
			self?.goToAuth()
			AlertHelper.showAlert(title: Str.error, detailText: Str.signInFailed, actions: [AlertHelper.AlertAction(withTitle: Str.ok)])
		}
	}
}
