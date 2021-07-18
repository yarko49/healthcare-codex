//
//  MainAppCoordinator.swift
//  Allie
//

import CareKitStore
import Combine
import HealthKit
import LocalAuthentication
import ModelsR4
import UIKit

class AppCoordinator: BaseCoordinator {
	weak var parent: MainCoordinator?
	var tabBarController: UITabBarController?

	override var rootViewController: UIViewController? {
		tabBarController
	}

	var organizations = CHOrganizations(available: [], registered: [])
	var observation: ModelsR4.Observation?
	var bundle: ModelsR4.Bundle?
	var observationSearch: String?

	init(parent: MainCoordinator?, organizations: CHOrganizations) {
		super.init(type: .application)
		self.parent = parent
		self.organizations = organizations

		let todayController: UIViewController
		let chatController: UIViewController
		if organizations.registered.isEmpty {
			var controller = Self.connectProviderController
			controller.showProviderList = { [weak self] in
				self?.showProviderList()
			}
			todayController = controller
			// second Instance
			controller = Self.connectProviderController
			controller.showProviderList = { [weak self] in
				self?.showProviderList()
			}
			chatController = controller
		} else {
			todayController = Self.dailyTasksController
			chatController = Self.conversationsListViewController
		}
		self.todayNavController = Self.todayNavController(rootViewController: todayController)
		self.conversationsNavController = Self.conversationsNavController(rootViewController: chatController)
		self.tabBarController = UITabBarController()
		tabBarController?.viewControllers = [todayNavController!, Self.profileNavController, Self.settingsNavController]
		start()
	}

	private var todayNavController: UINavigationController?
	private var conversationsNavController: UINavigationController?

	override func start() {
		super.start()

		if UserDefaults.standard.haveAskedUserForBiometrics == false {
			enrollWithBiometrics()
		}

		NotificationCenter.default.publisher(for: .didRegisterOrganization)
			.sink { [weak self] _ in
				self?.organizaionRegistraionDidChange()
			}.store(in: &cancellables)

		NotificationCenter.default.publisher(for: .didUnregisterOrganization)
			.sink { [weak self] _ in
				self?.organizaionRegistraionDidChange()
			}.store(in: &cancellables)
	}

	func showHUD(animated: Bool = true) {
		parent?.showHUD(animated: animated)
	}

	func hideHUD(animated: Bool = true) {
		parent?.hideHUD(animated: animated)
	}

	func evaluateBiometrics() {
		var theError: NSError?
		authenticationContext.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &theError)
		if authenticationContext.biometryType == .none {
			ALog.error("Error", error: theError)
			return
		}
		ALog.info("\(String(describing: authenticationContext.biometryType.rawValue))")
	}

	func enrollWithBiometrics() {
		evaluateBiometrics()
		UserDefaults.standard.haveAskedUserForBiometrics = true
		let yesTitle = NSLocalizedString("YES", comment: "Yes")
		let okAction = AlertHelper.AlertAction(withTitle: yesTitle) {
			UserDefaults.standard.isBiometricsEnabled = true
		}
		let noTitle = NSLocalizedString("NO", comment: "No")
		let noAction = AlertHelper.AlertAction(withTitle: noTitle) {
			UserDefaults.standard.isBiometricsEnabled = false
		}
		DispatchQueue.main.async {
			let biometricType = self.authenticationContext.biometryType == .faceID ? String.faceID : String.touchID
			AlertHelper.showAlert(title: String.automaticSignIn, detailText: String.enroll(biometricType), actions: [okAction, noAction])
		}
	}

	func gotoProfileEntryViewController(from screen: NavigationSourceType = .profile) {
		let viewController = ProfileEntryViewController()
		let alliePatient = CareManager.shared.patient
		viewController.fullName = alliePatient?.name.fullName
		viewController.sex = alliePatient?.sex ?? .male
		if let dob = alliePatient?.birthday {
			viewController.dateOfBirth = dob
		}
		if let weight = alliePatient?.profile.weightInPounds {
			viewController.weightInPounds = weight
		}
		if let height = alliePatient?.profile.heightInInches {
			viewController.heightInInches = height
		}
		viewController.doneAction = { [weak self] in
			var patient = CareManager.shared.patient
			if let name = PersonNameComponents(fullName: viewController.fullName) {
				patient?.name = name
			}
			patient?.sex = viewController.sex
			patient?.updatedDate = Date()
			patient?.birthday = viewController.dateOfBirth
			patient?.profile.weightInPounds = viewController.weightInPounds
			patient?.profile.heightInInches = viewController.heightInInches
			CareManager.shared.patient = patient
			self?.uploadPatient(patient: patient!)
			self?.navigationController?.popViewController(animated: true)
		}
		navigate(to: viewController, with: .push)
	}

	func logout() {
		parent?.logout()
	}

	deinit {
		navigationController?.viewControllers = []
		rootViewController?.dismiss(animated: true, completion: nil)
	}

	func organizaionRegistraionDidChange(animated: Bool = true) {
		APIClient.shared.getOrganizations()
			.receive(on: DispatchQueue.main)
			.sink { [weak self] organizations in
				self?.updateControllers(organizations: organizations)
			}.store(in: &cancellables)
	}

	func updateControllers(organizations: CHOrganizations) {
		self.organizations = organizations
		if organizations.registered.isEmpty {
			let todayController = Self.connectProviderController
			todayController.showProviderList = { [weak self] in
				self?.showProviderList()
			}
			// second Instance
			let chatController = Self.connectProviderController
			chatController.showProviderList = { [weak self] in
				self?.showProviderList()
			}
			// swap chat/today view controller to select organization
			todayNavController?.setViewControllers([todayController], animated: true)
			conversationsNavController?.setViewControllers([chatController], animated: true)
		} else {
			todayNavController?.setViewControllers([Self.dailyTasksController], animated: true)
			conversationsNavController?.setViewControllers([Self.conversationsListViewController], animated: true)
		}
	}

	func showProviderList() {
		let selectProviderController = SelectProviderViewController(collectionViewLayout: SelectProviderViewController.layout)
		selectProviderController.doneAction = { [weak selectProviderController] _ in
			selectProviderController?.dismiss(animated: true, completion: nil)
		}
		let navController = UINavigationController(rootViewController: selectProviderController)
		tabBarController?.showDetailViewController(navController, sender: navigationController)
	}

	class var connectProviderController: ConnectProviderViewController {
		let controller = ConnectProviderViewController()
		let title = NSLocalizedString("CONNECT", comment: "Connect")
		controller.title = title
		return controller
	}

	class var dailyTasksController: DailyTasksPageViewController {
		let controller = DailyTasksPageViewController(storeManager: CareManager.shared.synchronizedStoreManager)
		let title = NSLocalizedString("TODAY", comment: "Today")
		controller.title = title
		return controller
	}

	class func todayNavController(rootViewController controller: UIViewController) -> UINavigationController {
		let navigationController = UINavigationController(rootViewController: controller)
		navigationController.tabBarItem.image = UIImage(named: "icon-tabbar-today")
		navigationController.tabBarItem.imageInsets = UIEdgeInsets(top: 5.0, left: 0.0, bottom: -5.0, right: 0.0)
		navigationController.tabBarItem.title = nil
		return navigationController
	}

	class var profileViewController: ProfileViewController {
		let controller = ProfileViewController()
		let title = NSLocalizedString("PROFILE", comment: "Profile")
		controller.title = title
		return controller
	}

	class var profileNavController: UINavigationController {
		let controller = profileViewController
		let navigationController = UINavigationController(rootViewController: controller)
		let title = NSLocalizedString("PROFILE", comment: "Profile")
		navigationController.title = title
		navigationController.tabBarItem.image = UIImage(named: "icon-tabbar-profile")
		navigationController.tabBarItem.title = nil
		navigationController.tabBarItem.imageInsets = UIEdgeInsets(top: 5.0, left: 0.0, bottom: -5.0, right: 0.0)
		return navigationController
	}

	class var conversationsListViewController: ConversationListViewController {
		let controller = ConversationListViewController(collectionViewLayout: ConversationListViewController.layout)
		let title = NSLocalizedString("CHAT", comment: "Chat")
		controller.title = title
		return controller
	}

	class func conversationsNavController(rootViewController viewController: UIViewController) -> UINavigationController {
		let navigationController = UINavigationController(rootViewController: viewController)
		navigationController.tabBarItem.image = UIImage(named: "icon-tabbar-chat")
		navigationController.tabBarItem.title = nil
		navigationController.tabBarItem.imageInsets = UIEdgeInsets(top: 5.0, left: 0.0, bottom: -5.0, right: 0.0)
		return navigationController
	}

	class var settingsViewController: SettingsViewController {
		let controller = SettingsViewController()
		let title = NSLocalizedString("SETTINGS", comment: "Settings")
		controller.title = title
		return controller
	}

	class var settingsNavController: UINavigationController {
		let navigationController = UINavigationController(rootViewController: settingsViewController)
		navigationController.tabBarItem.image = UIImage(named: "icon-tabbar-settings")
		navigationController.tabBarItem.title = nil
		navigationController.tabBarItem.imageInsets = UIEdgeInsets(top: 5.0, left: 0.0, bottom: -5.0, right: 0.0)
		return navigationController
	}
}
