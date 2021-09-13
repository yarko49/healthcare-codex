//
//  AppDelegate.swift
//  Allie
//
//  Created by Waqar Malik on 12/17/20.
//

import Combine
import Firebase
import FirebaseAnalytics
import FirebaseAuth
import FirebaseCore
import FirebaseCrashlytics
import FirebaseMessaging
import GoogleSignIn
import IQKeyboardManagerSwift
import KeychainAccess
import SupportProvidersSDK
import UIKit
import UserNotifications
import ZendeskCoreSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
	class var appDelegate: AppDelegate! {
		UIApplication.shared.delegate as? AppDelegate
	}

	class var mainCoordinator: MainCoordinator? {
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
		IQKeyboardManager.shared.enable = true
		Crashlytics.crashlytics()
		Self.configureZendesk()
		UNUserNotificationCenter.current().delegate = self
		Messaging.messaging().delegate = self
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
		CoreLogger.enabled = false
		CoreLogger.logLevel = .debug
		Zendesk.initialize(appId: AppConfig.zendeskAppId, clientId: AppConfig.zendeskClientId, zendeskUrl: AppConfig.zendeskURL)
		Support.initialize(withZendesk: Zendesk.instance)
		let ident = Identity.createAnonymous()
		Zendesk.instance?.setIdentity(ident)
		ALog.trace("Zendesk Initialized")
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

	func registerForPushNotifications(application: UIApplication) {
		UNUserNotificationCenter.current().delegate = self
		let options: UNAuthorizationOptions = [.alert, .badge, .sound, .criticalAlert]
		DispatchQueue.main.async {
			UNUserNotificationCenter.current().requestAuthorization(options: options) { isGranted, _ in
				if isGranted {
					DispatchQueue.main.async {
						application.registerForRemoteNotifications()
					}
				}
			}
		}
	}

	@Injected(\.keychain) private var keychain: Keychain
	@Injected(\.networkAPI) private var networkAPI: AllieAPI
	var uploadTokenCancellable: AnyCancellable?
	func uploadRemoteNofication(token: String) {
		uploadTokenCancellable?.cancel()
		uploadTokenCancellable = networkAPI.uploadRemoteNotification(token: token)
			.sink(receiveCompletion: { completionResult in
				if case .failure(let error) = completionResult {
					ALog.error("Failed to uploaded remote notification token", error: error)
				}
			}, receiveValue: { result in
				ALog.trace("Token sent to server with result \(result)")
			})
	}

	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		ALog.trace("didRegisterForRemoteNotificationsWithDeviceToken:")
		Messaging.messaging().apnsToken = deviceToken
		if let fcmToken = Messaging.messaging().fcmToken {
			uploadRemoteNofication(token: fcmToken)
		} else {
			Messaging.messaging().token { [weak self] newToken, error in
				guard let token = newToken, error != nil else {
					ALog.error("Unable to get fcm Token", error: error ?? AllieError.invalid("FCM Token Missing"))
					return
				}
				self?.keychain.fcmToken = token
				self?.uploadRemoteNofication(token: token)
			}
		}
	}

	func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
		ALog.error("didFailToRegisterForRemoteNotificationsWithError", error: error)
	}

	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
		ALog.debug("didReceiveRemoteNotification:")
		if application.applicationState != .active {
			process(application, notificationInfo: userInfo)
		}
		completionHandler(UIBackgroundFetchResult.newData)
	}

	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		// Show Tabbar and download messages
	}

	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		ALog.debug("willPresent notification:")
		process(UIApplication.shared, notificationRequest: notification.request)
		completionHandler([.badge, .banner, .sound])
	}

	func process(_ application: UIApplication, notificationRequest: UNNotificationRequest?) {
		guard let request = notificationRequest else {
			return
		}

		let userInfo = request.content.userInfo
		process(application, notificationInfo: userInfo)
	}

	func process(_ application: UIApplication, notificationInfo userInfo: [AnyHashable: Any]) {
		Messaging.messaging().appDidReceiveMessage(userInfo)
		guard let typeString = userInfo["type"] as? String else {
			return
		}
		if typeString == "chat" {
			ALog.trace("process notificationInfo: applicationState: \(application.applicationState.rawValue)")
			let count = UserDefaults.standard.chatNotificationsCount + 1
			application.applicationIconBadgeNumber = count
			AppDelegate.mainCoordinator?.updateBadges(count: count)
			UserDefaults.standard.chatNotificationsCount = count
		} else if typeString == "careplan" {
			NotificationCenter.default.post(name: .didUpdateCarePlan, object: nil)
		}
	}
}

extension AppDelegate: MessagingDelegate {
	func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
		guard let token = fcmToken else {
			return
		}
		ALog.trace("messaging:didReceiveRegistrationToken: \(token)")
		keychain.fcmToken = token
		uploadRemoteNofication(token: token)
	}
}
