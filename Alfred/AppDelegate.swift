import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseCrashlytics
import GoogleSignIn
import IQKeyboardManagerSwift
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
	class var appDelegate: AppDelegate! {
		UIApplication.shared.delegate as? AppDelegate
	}

	var careManager = CareManager()
	class var primaryWindow: UIWindow! {
		UIApplication.shared.windows.first
	}

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		FirebaseApp.configure()
		Crashlytics.crashlytics()
		GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
		IQKeyboardManager.shared.enable = true
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
}
