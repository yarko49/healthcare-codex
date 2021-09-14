//
//  SceneDelegate.swift
//  Allie
//
//  Created by Waqar Malik on 12/17/20.
//

import Firebase
import FirebaseDynamicLinks
import KeychainAccess
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	var window: UIWindow?
	@Injected(\.keychain) var keychain: Keychain

	lazy var mainCoordinator: MainCoordinator = {
		MainCoordinator(window: self.window!)
	}()

	private var connectionOptions: UIScene.ConnectionOptions?

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		// Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
		// If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
		// This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
		guard let scene = (scene as? UIWindowScene) else {
			return
		}
		ALog.trace("willConnectTo session: State \(UIApplication.shared.applicationState.rawValue)")
		self.connectionOptions = connectionOptions
		window = UIWindow(windowScene: scene)
	}

	func sceneDidDisconnect(_ scene: UIScene) {
		// Called as the scene is being released by the system.
		// This occurs shortly after the scene enters the background, or when its session is discarded.
		// Release any resources associated with this scene that can be re-created the next time the scene connects.
		// The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
	}

	private var didStartOnce: Bool = false
	func sceneDidBecomeActive(_ scene: UIScene) {
		// Called when the scene has moved from an inactive state to an active state.
		// Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
		ALog.trace("sceneDidBecomeActive: state = \(UIApplication.shared.applicationState.rawValue)")
		if didStartOnce == false {
			didStartOnce = true
			if let incomingURL = connectionOptions?.userActivities.first?.webpageURL {
				handleIncomingURL(incomingURL)
			} else {
				mainCoordinator.start()
			}
		}

		AnalyticsManager.send(event: .session, properties: nil)
		if UIApplication.shared.applicationState == .inactive || UIApplication.shared.applicationState == .active {
			let count = UserDefaults.standard.chatNotificationsCount
			mainCoordinator.updateBadges(count: count)
			Auth.auth().currentUser?.getIDTokenResult(forcingRefresh: true, completion: { authTokenResult, error in
				if let token = AuthenticationToken(result: authTokenResult), error == nil {
					self.keychain.authenticationToken = token
				} else if let error = error {
					ALog.error("Error refreshing token \(error.localizedDescription)")
				}
			})
		}
	}

	func sceneWillResignActive(_ scene: UIScene) {
		// Called when the scene will move from an active state to an inactive state.
		// This may occur due to temporary interruptions (ex. an incoming phone call).
	}

	func sceneWillEnterForeground(_ scene: UIScene) {
		// Called as the scene transitions from the background to the foreground.
		// Use this method to undo the changes made on entering the background.
		ALog.info("sceneWillEnterForeground:")
	}

	func sceneDidEnterBackground(_ scene: UIScene) {
		ALog.info("sceneDidEnterBackground:")
		// Called as the scene transitions from the foreground to the background.
		// Use this method to save data, release shared resources, and store enough scene-specific state information
		// to restore the scene back to its current state.
	}

	func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
		ALog.info("sceneDidEnterBackground: \(String(describing: userActivity.webpageURL))")
		if let incomingURL = userActivity.webpageURL {
			handleIncomingURL(incomingURL)
		} else {
			mainCoordinator.start()
		}
	}

	func handleIncomingURL(_ incomingURL: URL) {
		DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { [weak self] dynamicLink, error in
			if let error = error {
				ALog.error("Error", error: error)
				return
			}
			if let dynamicLink = dynamicLink {
				self?.handleIncomingDynamicLink(dynamicLink)
			}
		}
	}

	func handleIncomingDynamicLink(_ dynamicLink: DynamicLink) {
		guard let url = dynamicLink.url else {
			ALog.error("No Dynamic Link Url")
			return
		}
		ALog.info("handleIncomingDynamicLink: \(dynamicLink)")
		DispatchQueue.main.async { [weak self] in
			if let authCoordinator = (self?.mainCoordinator.childCoordinators[.authentication] as? AuthCoordinator) {
				authCoordinator.verifySendLink(link: url.absoluteString)
			} else {
				self?.mainCoordinator.goToAuth(url: url.absoluteString)
			}
		}
	}
}
