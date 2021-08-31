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
class AppDelegate: UIResponder, UIApplicationDelegate {
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
		Messaging.messaging().delegate = self

		let notificationOption = launchOptions?[.remoteNotification]
		if let notification = notificationOption as? [String: AnyObject], notification["aps"] as? [String: AnyObject] != nil {
			AppDelegate.mainCoordinator?.showMessagesTab()
		}
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

	func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
		ALog.info("url = \(url), options = \(options)")
		return true
	}

	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		ALog.info("didRegisterForRemoteNotificationsWithDeviceToken:")
		Messaging.messaging().apnsToken = deviceToken
		if let fcmToken = Messaging.messaging().fcmToken {
			uploadRemoteNofication(token: fcmToken)
		} else {
			Messaging.messaging().token { [weak self] newToken, error in
				guard let token = newToken, error != nil else {
					ALog.error("Unable to get fcm Token", error: error ?? AllieError.invalid("FCM Token Missing"))
					return
				}
				self?.uploadRemoteNofication(token: token)
			}
		}
	}

	func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
		ALog.error("didFailToRegisterForRemoteNotificationsWithError", error: error)
	}

	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
		Messaging.messaging().appDidReceiveMessage(userInfo)
		application.applicationIconBadgeNumber += 1
		AppDelegate.mainCoordinator?.updateBadges(count: application.applicationIconBadgeNumber)
		completionHandler(UIBackgroundFetchResult.newData)
	}

	static func configureZendesk() {
		CoreLogger.enabled = true
		CoreLogger.logLevel = .debug
		Zendesk.initialize(appId: AppConfig.zendeskAppId, clientId: AppConfig.zendeskClientId, zendeskUrl: AppConfig.zendeskURL)
		Support.initialize(withZendesk: Zendesk.instance)
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

	func registerForPushNotifications(application: UIApplication) {
		UNUserNotificationCenter.current().delegate = self
		let options: UNAuthorizationOptions = [.alert, .badge, .sound]
		DispatchQueue.main.async {
			UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, _ in
				if granted {
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
				ALog.info("Token sent to server with result \(result)")
			})
	}
}

extension AppDelegate: UNUserNotificationCenterDelegate {
	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		let userInfo = response.notification.request.content.userInfo
		Messaging.messaging().appDidReceiveMessage(userInfo)
		let application = UIApplication.shared
		application.applicationIconBadgeNumber += 1
		AppDelegate.mainCoordinator?.updateBadges(count: application.applicationIconBadgeNumber)
		completionHandler()
	}

	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		let userInfo = notification.request.content.userInfo
		Messaging.messaging().appDidReceiveMessage(userInfo)
		let application = UIApplication.shared
		application.applicationIconBadgeNumber += 1
		AppDelegate.mainCoordinator?.updateBadges(count: application.applicationIconBadgeNumber)
		completionHandler([.badge, .banner, .sound])
	}
}

extension AppDelegate: MessagingDelegate {
	func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
		guard let token = fcmToken else {
			return
		}
		ALog.info("messaging:didReceiveRegistrationToken: \(token)")
		keychain.fcmToken = token
		uploadRemoteNofication(token: token)
	}
}
