import AnswerBotProvidersSDK
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseCrashlytics
import GoogleSignIn
import IQKeyboardManagerSwift
import SupportProvidersSDK
import UIKit
import ZendeskCoreSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
	class var appDelegate: AppDelegate! {
		UIApplication.shared.delegate as? AppDelegate
	}

	class var appCoordinator: MainCoordinator? {
		(primaryWindow.windowScene?.delegate as? SceneDelegate)?.mainCoordinator
	}

	class var primaryWindow: UIWindow! {
		Self.appDelegate.primaryWindow
	}

	var primaryWindow: UIWindow! {
		UIApplication.shared.windows.first
	}

	var keyWindow: UIWindow! {
		primaryWindow
	}

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		applyAppearance()
		UserDefaults.registerDefautlts()
		FirebaseConfiguration.shared.setLoggerLevel(.min)
		FirebaseApp.configure()
		GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
		IQKeyboardManager.shared.enable = true
		Crashlytics.crashlytics()
		Self.configureZendesk()
		return true
	}

	// MARK: UISceneSession Lifecycle

	func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
		// Called when a new scene session is being created.
		// Use this method to select a configuration to create the new scene with.
		UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}

	func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
		// Called when the user discards a scene session.
		// If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
		// Use this method to release any resources that were specific to the discarded scenes, as they will not return.
	}

	var backgroundCompletionHandlers: [String: () -> Void] = [:]

	func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
		backgroundCompletionHandlers[identifier] = completionHandler
	}

	func finishBackgroundUpload(forBackgroundURLSession identifier: String) {
		guard let handler = backgroundCompletionHandlers.removeValue(forKey: identifier) else {
			return
		}
		handler()
	}

	static func configureZendesk() {
		CoreLogger.enabled = true
		CoreLogger.logLevel = .debug
		Zendesk.initialize(appId: AppConfig.zendeskAppId, clientId: AppConfig.zendeskClientId, zendeskUrl: AppConfig.zendeskURL)
		Support.initialize(withZendesk: Zendesk.instance)
		AnswerBot.initialize(withZendesk: Zendesk.instance, support: Support.instance!)
		let ident = Identity.createAnonymous()
		Zendesk.instance?.setIdentity(ident)
		ALog.info("Zendesk Initialized")
	}

	static func configureZendeskIdentity(name: String? = nil, email: String? = nil) {
		let identity = Identity.createAnonymous(name: name, email: email)
		Zendesk.instance?.setIdentity(identity)
	}

	static func registerServices(patient: CHPatient?) {
		guard let patient = patient else {
			return
		}
		LoggingManager.identify(userId: patient.id)
		AppDelegate.configureZendeskIdentity(name: patient.name.fullName, email: patient.profile.email)
		Analytics.setUserID(patient.id)
		Crashlytics.crashlytics().setUserID(patient.id)
	}

	func applyAppearance() {
		UINavigationBar.applyAppearance()
		UITabBar.applyAppearance()
		UICollectionView.applyAppearance()
	}
}
