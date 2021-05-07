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

class AppCoordinator: NSObject, Coordinable, UIViewControllerTransitioningDelegate {
	var navigationController: UINavigationController?
	let type: CoordinatorType = .appCoordinator
	var cancellables: Set<AnyCancellable> = []
	var childCoordinators: [CoordinatorType: Coordinable]
	weak var parentCoordinator: MainCoordinator?
	var tabBarController: UITabBarController?

	var laContext = LAContext()

	var rootViewController: UIViewController? {
		tabBarController
	}

	var observation: ModelsR4.Observation?
	var bundle: ModelsR4.Bundle?
	var observationSearch: String?
	weak var profileViewController: ProfileViewController?

	init(with parent: MainCoordinator?) {
		self.tabBarController = Self.tabBarController
		self.parentCoordinator = parent
		self.childCoordinators = [:]
		super.init()
		parentCoordinator?.registerServices()
		start()
	}

	func start() {
		if UserDefaults.standard.haveAskedUserForBiometrics == false {
			enrollWithBiometrics()
		} else {
			if UserDefaults.standard.isBiometricsEnabled == false {}
		}
	}

	func showHUD(animated: Bool = true) {
		parentCoordinator?.showHUD(animated: animated)
	}

	func hideHUD(animated: Bool = true) {
		parentCoordinator?.hideHUD(animated: animated)
	}

	func evaluateBiometrics() {
		var theError: NSError?
		let context = laContext
		laContext.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &theError)
		if laContext.biometryType == .none {
			ALog.error("Error", error: theError)
			return
		}
		ALog.info("\(String(describing: context.biometryType.rawValue))")
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
			let biometricType = self.laContext.biometryType == .faceID ? Str.faceID : Str.touchID
			AlertHelper.showAlert(title: Str.automaticSignIn, detailText: Str.enroll(biometricType), actions: [okAction, noAction])
		}
	}

	func goToInput(with type: HKQuantityTypeIdentifier) {
		let todayInputViewController = TodayInputViewController()
		todayInputViewController.quantityTypeIdentifier = type
		let inputAction: ((Int, Int, Date, HKQuantityTypeIdentifier) -> Void)? = { [weak self] value1, value2, effectiveDateTime, inputType in
			do {
				let factory = try ObservationFactory()
				switch inputType {
				case .bloodPressureSystolic:
					let observation = try factory.observation(from: [Double(value1), Double(value2)], identifier: HKCorrelationTypeIdentifier.bloodPressure.rawValue, date: effectiveDateTime)
					observation.subject = AppDelegate.careManager.patient?.subject
					self?.observation = observation
					self?.bundle = nil
				case .bodyMass:
					let weightObservation = try factory.observation(from: [Double(value1)], identifier: HKQuantityTypeIdentifier.bodyMass.rawValue, date: effectiveDateTime)
					let qoalObservation = try factory.observation(from: [Double(value2)], identifier: "HKQuantityTypeIdentifierIdealBodyMass", date: effectiveDateTime)
					let observationPath = "/mobile/fhir/Observation"
					let request = ModelsR4.BundleEntryRequest(method: FHIRPrimitive<HTTPVerb>(HTTPVerb.POST), url: FHIRPrimitive<FHIRURI>(stringLiteral: observationPath))
					let fullURL = FHIRPrimitive<FHIRURI>(stringLiteral: AppConfig.apiBaseUrl + observationPath)
					let weightEntry = ModelsR4.BundleEntry(extension: nil, fullUrl: fullURL, id: nil, link: nil, modifierExtension: nil, request: request, resource: .observation(weightObservation), response: nil, search: nil)
					let goalWeightEntry = ModelsR4.BundleEntry(extension: nil, fullUrl: fullURL, id: nil, link: nil, modifierExtension: nil, request: request, resource: .observation(qoalObservation), response: nil, search: nil)
					let bundle = ModelsR4.Bundle(entry: [weightEntry, goalWeightEntry], type: FHIRPrimitive<BundleType>(.transaction))
					self?.observation = nil
					self?.bundle = bundle
				default:
					break
				}
			} catch {
				ALog.error("\(error.localizedDescription)")
			}
		}
		todayInputViewController.inputAction = inputAction
		navigate(to: todayInputViewController, with: .push)
	}

	func gotoProfileEntryViewController(from screen: NavigationSourceType = .profile) {
		let viewController = ProfileEntryViewController()
		let alliePatient = AppDelegate.careManager.patient
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
			var patient = AppDelegate.careManager.patient
			if let name = PersonNameComponents(fullName: viewController.fullName) {
				patient?.name = name
			}
			patient?.sex = viewController.sex
			patient?.updatedDate = Date()
			patient?.birthday = viewController.dateOfBirth
			patient?.profile.weightInPounds = viewController.weightInPounds
			patient?.profile.heightInInches = viewController.heightInInches
			AppDelegate.careManager.patient = patient
			self?.parentCoordinator?.uploadPatient(patient: patient!)
			self?.navigationController?.popViewController(animated: true)
		}
		navigate(to: viewController, with: .push)
	}

	func postGetData(search: SearchParameter, completion: @escaping (ModelsR4.Bundle?) -> Void) {}

	func postObservationSearchAction(search: SearchParameter, viewController: ProfileViewController, start: Date, end: Date, hkType: HealthKitQuantityType) {}

	func logout() {
		parentCoordinator?.logout()
	}

	deinit {
		navigationController?.viewControllers = []
		rootViewController?.dismiss(animated: true, completion: nil)
	}

	@objc internal func backAction() {
		navigationController?.popViewController(animated: true)
	}

	@objc internal func addAction() {
		if let observation = observation {
			showHUD()
			APIClient.shared.post(observation: observation) { [weak self] result in
				self?.hideHUD()
				switch result {
				case .failure(let error):
					ALog.error("Error posting Observation", error: error)
				case .success:
					self?.observation = nil
					self?.navigationController?.popViewController(animated: true)
				}
			}
		} else if let bundle = bundle {
			showHUD()
			APIClient.shared.post(bundle: bundle) { [weak self] result in
				self?.hideHUD()
				switch result {
				case .failure(let error):
					ALog.error("Error posting Bundle", error: error)
				case .success:
					self?.bundle = nil
					self?.navigationController?.popViewController(animated: true)
				}
			}
		}
	}

	class var todayViewController: UINavigationController {
		let controller = DailyTasksPageViewController(storeManager: AppDelegate.careManager.synchronizedStoreManager)
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
