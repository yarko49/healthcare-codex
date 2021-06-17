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
	lazy var tabBarController: UITabBarController? = {
		Self.tabBarController
	}()

	override var rootViewController: UIViewController? {
		tabBarController
	}

	var observation: ModelsR4.Observation?
	var bundle: ModelsR4.Bundle?
	var observationSearch: String?

	init(parent: MainCoordinator?) {
		super.init(type: .application)
		self.parent = parent
		start()
	}

	override func start() {
		super.start()
		if UserDefaults.standard.haveAskedUserForBiometrics == false {
			enrollWithBiometrics()
		}
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

	class var todayViewController: UINavigationController {
		let controller = DailyTasksPageViewController(storeManager: CareManager.shared.synchronizedStoreManager)
		let title = NSLocalizedString("TODAY", comment: "Today")
		controller.title = title
		controller.tabBarItem.image = UIImage(named: "icon-tabbar-today")
		controller.tabBarItem.imageInsets = UIEdgeInsets(top: 5.0, left: 0.0, bottom: -5.0, right: 0.0)
		controller.tabBarItem.title = nil
		let navigationController = UINavigationController(rootViewController: controller)
		return navigationController
	}

	class var profileViewController: UINavigationController {
		let controller = ProfileViewController()
		let title = NSLocalizedString("PROFILE", comment: "Profile")
		controller.title = title
		controller.tabBarItem.image = UIImage(named: "icon-tabbar-profile")
		controller.tabBarItem.title = nil
		controller.tabBarItem.imageInsets = UIEdgeInsets(top: 5.0, left: 0.0, bottom: -5.0, right: 0.0)
		let navigationController = UINavigationController(rootViewController: controller)
		return navigationController
	}

	class var chatViewController: UINavigationController {
		let layout = UICollectionViewFlowLayout()
		let controller = ChatViewController(collectionViewLayout: layout)
		let title = NSLocalizedString("CHAT", comment: "Chat")
		controller.title = title
		controller.tabBarItem.image = UIImage(named: "icon-tabbar-chat")
		controller.tabBarItem.title = nil
		controller.tabBarItem.imageInsets = UIEdgeInsets(top: 5.0, left: 0.0, bottom: -5.0, right: 0.0)
		let navigationController = UINavigationController(rootViewController: controller)
		return navigationController
	}

	class var settingsViewController: UINavigationController {
		let controller = SettingsViewController()
		let title = NSLocalizedString("SETTINGS", comment: "Settings")
		controller.title = title
		controller.tabBarItem.image = UIImage(named: "icon-tabbar-settings")
		controller.tabBarItem.title = nil
		controller.tabBarItem.imageInsets = UIEdgeInsets(top: 5.0, left: 0.0, bottom: -5.0, right: 0.0)
		let navigationController = UINavigationController(rootViewController: controller)
		return navigationController
	}

	class var tabBarController: UITabBarController {
		let controller = UITabBarController()
		controller.viewControllers = [todayViewController, profileViewController, settingsViewController]
		return controller
	}
}
