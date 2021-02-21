import AnswerBotProvidersSDK
import ChatProvidersSDK
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

	class var carePlanStoreManager: CarePlanStoreManager {
		AppDelegate.appDelegate.carePlanStoreManager
	}

	var carePlanStoreManager = CarePlanStoreManager()

	class var primaryWindow: UIWindow! {
		AppDelegate.appDelegate.primaryWindow
	}

	var primaryWindow: UIWindow! {
		UIApplication.shared.windows.first
	}

	var keyWindow: UIWindow! {
		primaryWindow
	}

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		FirebaseConfiguration.shared.setLoggerLevel(.min)
		FirebaseApp.configure()
		Crashlytics.crashlytics()
		GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
		IQKeyboardManager.shared.enable = true
		Self.configureZendesk()
		UINavigationBar.applyAppearance()
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

	static func configureZendesk() {
		Zendesk.initialize(appId: AppConfig.zendeskAppId, clientId: AppConfig.zendeskClientId, zendeskUrl: AppConfig.zendeskURL)
		Support.initialize(withZendesk: Zendesk.instance)
		Chat.initialize(accountKey: AppConfig.zendeskChatAccountKey, appId: AppConfig.zendeskChatAppId)
		AnswerBot.initialize(withZendesk: Zendesk.instance, support: Support.instance!)
		ALog.info("Zendesk Initialized")
	}

	static func configureChat(name: String, email: String, phoneNumber: String?) {
		let chatAPIConfiguration = ChatAPIConfiguration()
		chatAPIConfiguration.department = "Department name"
		chatAPIConfiguration.visitorInfo = VisitorInfo(name: name, email: email, phoneNumber: phoneNumber ?? "")
		Chat.instance?.configuration = chatAPIConfiguration
	}
}
