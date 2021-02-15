import Firebase
import FirebaseAuth
import JGProgressHUD
import LocalAuthentication
import UIKit

class MasterCoordinator: Coordinator {
	private var window: UIWindow
	internal var childCoordinators: [CoordinatorKey: Coordinator]
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
		NotificationCenter.default.addObserver(self, selector: #selector(handleLogout(_:)), name: .applicationDidLogout, object: nil)
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
						self?.syncHKData()
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
			guard let user = Auth.auth().currentUser else {
				completion(false)
				return
			}

			DataContext.shared.searchPatient(user: user) { success in
				guard success else {
					completion(false)
					return
				}
				LoggingManager.identify(userId: DataContext.shared.userModel?.userID)
				DataContext.shared.getProfileAPI(completion: completion)
			}
		})
	}

	internal func syncHKData() {
		let hkDataUploadViewController = HKDataUploadViewController()
		window.rootViewController = hkDataUploadViewController
		SyncManager.shared.syncData(initialUpload: false, chunkSize: 4500) { [weak hkDataUploadViewController] uploaded, total in
			hkDataUploadViewController?.maxProgress = total
			hkDataUploadViewController?.progress = uploaded
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
		} catch let signOutError {
			ALog.error("Error signing out:", error: signOutError)
		}
		DispatchQueue.main.async { [weak self] in
			self?.goToAuth()
			AlertHelper.showAlert(title: Str.error, detailText: Str.signInFailed, actions: [AlertHelper.AlertAction(withTitle: Str.ok)])
		}
	}
}
