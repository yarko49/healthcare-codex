//
//  MainAppCoordinator.swift
//  Allie
//

import CareKitStore
import CodexFoundation
import CodexModel
import Combine
import HealthKit
import KeychainAccess
import LocalAuthentication
import UIKit

@MainActor
class AppCoordinator: BaseCoordinator {
	weak var parent: MainCoordinator?
	var tabBarController: UITabBarController?

	override var rootViewController: UIViewController? {
		tabBarController
	}

	@KeychainStorage(Keychain.Keys.organizations)
	var organizations: CMOrganizations?

	var observationSearch: String?

	init(parent: MainCoordinator?) {
		super.init(type: .application)
		self.parent = parent

		let todayController: UIViewController
		let chatController: UIViewController
		if let organizations = organizations, organizations.registered.isEmpty {
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
//			todayController = Self.dailyTasksController
			todayController = Self.newDailyTasksController
			chatController = Self.conversationsListViewController
		}
		self.todayNavController = Self.todayNavController(rootViewController: todayController)
		self.conversationsNavController = Self.conversationsNavController(rootViewController: chatController)
//		self.tabBarController = UITabBarController()
		self.tabBarController = RoundedTabBarController()
//		tabBarController?.viewControllers = [todayNavController!, Self.profileNavController, conversationsNavController!, Self.settingsNavController]
		tabBarController?.viewControllers = [todayNavController!, Self.carePlanNavController, Self.chartNavController, Self.settingsNavController]
		start()
	}

	private var todayNavController: UINavigationController?
	private var conversationsNavController: UINavigationController?

	override func start() {
		super.start()

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

	func gotoToday() {
		guard let todayViewController = todayNavController?.topViewController as? DailyTasksPageViewController else {
			return
		}

		todayViewController.gotoToday(self)
	}

	func gotoProfileEntryViewController(from screen: NavigationSourceType = .profile) {
		let viewController = ProfileEntryViewController()
		let alliePatient = careManager.patient
		if let name = alliePatient?.name {
			viewController.name = name
		}
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
			var patient = self?.careManager.patient
			patient?.name = viewController.name
			patient?.sex = viewController.sex
			patient?.updatedDate = Date()
			patient?.birthday = viewController.dateOfBirth
			patient?.profile.weightInPounds = viewController.weightInPounds
			patient?.profile.heightInInches = viewController.heightInInches
			self?.careManager.patient = patient
			self?.uploadPatient(patient: patient!)
			self?.navigationController?.popViewController(animated: true)
		}
		navigate(to: viewController, with: .push)
	}

	func logout() {
		parent?.logout()
	}

	deinit {
		DispatchQueue.main.async { [weak self] in
			self?.navigationController?.viewControllers = []
			self?.rootViewController?.dismiss(animated: true, completion: nil)
		}
	}

	func organizaionRegistraionDidChange(animated: Bool = true) {
		Task { [weak self] in
			guard let strongSelf = self else {
				return
			}
			do {
				let organizations = try await strongSelf.networkAPI.getOrganizations()
				strongSelf.organizations = organizations
			} catch {
				ALog.error("Error getting organizations", error: error)
			}
			strongSelf.updateControllers(organizations: strongSelf.organizations)
		}
	}

	func updateControllers(organizations: CMOrganizations?) {
		guard let organizations = organizations else {
			return
		}

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
//			let todayViewController = Self.dailyTasksController
			let todayViewController = Self.newDailyTasksController
			todayNavController?.setViewControllers([todayViewController], animated: true)
			DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) { [weak todayViewController] in
				todayViewController?.reload()
			}
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

	class var newDailyTasksController: NewDailyTasksPageViewController {
		let controller = NewDailyTasksPageViewController()
		return controller
	}

	class func todayNavController(rootViewController controller: UIViewController) -> UINavigationController {
		let navigationController = UINavigationController(rootViewController: controller)
		navigationController.tabBarItem.image = UIImage(named: "icon-tab-home")?.withRenderingMode(.alwaysOriginal)
		navigationController.tabBarItem.selectedImage = UIImage(named: "icon-tab-home-selected")?.withRenderingMode(.alwaysOriginal)
		navigationController.tabBarItem.imageInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
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
		navigationController.tabBarItem.image = UIImage(named: "icon-tab-user")
		navigationController.tabBarItem.selectedImage = UIImage(named: "icon-tab-user-selected")
		navigationController.tabBarItem.title = nil
		navigationController.tabBarItem.imageInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
		return navigationController
	}

	class var conversationsListViewController: ChatViewController {
		let controller = ChatViewController()
		let title = NSLocalizedString("CHAT", comment: "Chat")
		controller.title = title
		return controller
	}

	class func conversationsNavController(rootViewController viewController: UIViewController) -> UINavigationController {
		let navigationController = UINavigationController(rootViewController: viewController)
		navigationController.tabBarItem.image = UIImage(named: "icon-tabbar-chat")
		navigationController.tabBarItem.title = nil
		navigationController.tabBarItem.imageInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
		return navigationController
	}

	class var carePlanViewController: CarePlanViewController {
		let controller = CarePlanViewController()
		return controller
	}

	class var carePlanNavController: UINavigationController {
		let navigationController = UINavigationController(rootViewController: carePlanViewController)
		navigationController.tabBarItem.image = UIImage(named: "icon-tab-user")?.withRenderingMode(.alwaysOriginal)
		navigationController.tabBarItem.selectedImage = UIImage(named: "icon-tab-user-selected")?.withRenderingMode(.alwaysOriginal)
		navigationController.tabBarItem.title = nil
		navigationController.tabBarItem.imageInsets = .zero
		return navigationController
	}

	class var chartViewController: ChartViewController {
		let controller = ChartViewController()
		return controller
	}

	class var chartNavController: UINavigationController {
		let navigationController = UINavigationController(rootViewController: chartViewController)
		navigationController.tabBarItem.image = UIImage(named: "icon-tab-chart")?.withTintColor(.mainGray!, renderingMode: .alwaysTemplate)
		navigationController.tabBarItem.selectedImage = UIImage(named: "icon-tab-chart-selected")?.withRenderingMode(.alwaysOriginal)
		navigationController.tabBarItem.title = nil
		navigationController.tabBarItem.imageInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
		return navigationController
	}

	class var settingsViewController: SettingsViewController {
		let controller = SettingsViewController()
		return controller
	}

	class var settingsNavController: UINavigationController {
		let navigationController = UINavigationController(rootViewController: settingsViewController)
		navigationController.tabBarItem.image = UIImage(named: "icon-tab-settings")?.withRenderingMode(.alwaysOriginal)
		navigationController.tabBarItem.selectedImage = UIImage(named: "icon-tab-settings-selected")?.withRenderingMode(.alwaysOriginal)
		navigationController.tabBarItem.title = nil
		navigationController.tabBarItem.imageInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
		return navigationController
	}
}
