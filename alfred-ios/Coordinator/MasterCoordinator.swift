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

	init(in window: UIWindow) {
		self.childCoordinators = [:]
		self.window = window
		self.window.rootViewController = rootViewController
		self.window.makeKeyAndVisible()
	}

	public func start() {
		NotificationCenter.default.addObserver(self, selector: #selector(handleLogout(_:)), name: .logoutNotification, object: nil)
		if !DataContext.shared.hasRunOnce {
			DataContext.shared.clearAll()
			let firebaseAuth = Auth.auth()
			do {
				try firebaseAuth.signOut()
			} catch let signOutError as NSError {
				print("Error signing out: %@", signOutError)
			}
			DataContext.shared.hasRunOnce = true
		}
		showMockSplashScreen()
	}

	internal func showMockSplashScreen() {
		let mockSplashVC = MockSplashVC()
		window.rootViewController = mockSplashVC

		if Auth.auth().currentUser == nil {
			DataContext.shared.clearAll()
			goToAuth()
		} else {
			if DataContext.shared.isBiometricsEnabled {
				biometricsAuthentication { completion in
					if completion {
						Auth.auth().tenantID = AppConfig.tenantID
						Auth.auth().currentUser?.getIDToken(completion: { firebaseToken, error in
							if let error = error {
								print(error)
								self.goToAuth()
							} else {
								if let firebaseToken = firebaseToken {
									DataContext.shared.authToken = firebaseToken
									guard let user = Auth.auth().currentUser else {
										self.goToAuth()
										return
									}
									DataContext.shared.fetchData(user: user) { [weak self] success in
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
		let hkDataUploadVC = HKDataUploadVC()
		SyncManager.shared.syncData(initialUpload: false, chunkSize: 4500) { [weak self] uploaded, total in
			if total > 500, loadingShouldAppear {
				loadingShouldAppear = false
				self?.window.rootViewController = hkDataUploadVC
			} else if total > 500 {
				hkDataUploadVC.progress = uploaded
				hkDataUploadVC.maxProgress = total
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

	public func goToAuth() {
		removeChild(.mainAppCoordinator)
		DataContext.shared.clearAll()
		let authCoordinator = AuthCoordinator(withParent: self)
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
			print("Error signing out: %@", signOutError)
		}
		DispatchQueue.main.async { [weak self] in
			self?.goToAuth()
			AlertHelper.showAlert(title: Str.error, detailText: Str.signInFailed, actions: [AlertHelper.AlertAction(withTitle: Str.ok)])
		}
	}
}
