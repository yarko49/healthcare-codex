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
	let type: CoordinatorType = .appCoordinator
	var cancellables: Set<AnyCancellable> = []

	internal var navigationController: UINavigationController?
	internal var childCoordinators: [CoordinatorType: Coordinable]
	internal weak var parentCoordinator: MainCoordinator?

	var laContext = LAContext()

	var rootViewController: UIViewController? {
		navigationController
	}

	var observation: ModelsR4.Observation?
	var bundle: ModelsR4.Bundle?
	var observationSearch: String?
	var chartData: [Int] = []
	var dateData: [String] = []
	weak var profileViewController: ProfileViewController?

	init(with parent: MainCoordinator?) {
		self.navigationController = UINavigationController()
		self.parentCoordinator = parent
		self.childCoordinators = [:]
		super.init()
		navigationController?.delegate = self

		start()
	}

	internal func start() {
		if UserDefaults.standard.haveAskedUserForBiometrics == false {
			enrollWithBiometrics()
		} else {
			if UserDefaults.standard.isBiometricsEnabled == false {}
		}
		showDailyTasksView()
	}

	func showHUD(animated: Bool = true) {
		parentCoordinator?.showHUD(animated: animated)
	}

	func hideHUD(animated: Bool = true) {
		parentCoordinator?.hideHUD(animated: animated)
	}

	internal func evaluateBiometrics() {
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

	internal func showDailyTasksView() {
		let tasksViewController = DailyTasksPageViewController(storeManager: AppDelegate.careManager.synchronizedStoreManager)
		navigate(to: tasksViewController, with: .push)
	}

	internal func gotoSettings() {
		let settingsCoord = SettingsCoordinator(with: self)
		addChild(coordinator: settingsCoord)
		settingsCoord.start()
	}

	internal func goToTroubleshooting(previewTitle: String?, title: String?, text: String?) {
		let troubleshootingViewController = TroubleshootingViewController()

		troubleshootingViewController.titleText = title ?? ""
		troubleshootingViewController.previewTitle = previewTitle ?? ""
		troubleshootingViewController.text = text ?? ""

		navigate(to: troubleshootingViewController, with: .push)
	}

	internal func goToInput(with type: HKQuantityTypeIdentifier) {
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

	internal func goToProfile() {
		let controller = ProfileViewController()
		profileViewController = controller

		controller.getData = { [weak self] in
			let patient = AppDelegate.careManager.patient
			self?.profileViewController?.age = patient?.age
			self?.profileViewController?.weight = patient?.profile.weightInPounds
			self?.profileViewController?.height = patient?.profile.heightInInches
			self?.profileViewController?.createDetailsLabel()
			self?.profileViewController?.patientTrendsTableView.reloadData()
		}

		var todayData: [HealthKitQuantityType: [Any]] = [:]
		let topGroup = DispatchGroup()
		HealthKitQuantityType.allCases.forEach { quantityType in
			if quantityType != .activity {
				topGroup.enter()
				let innergroup = DispatchGroup()
				var values: [Any] = []
				quantityType.healthKitQuantityTypeIdentifiers.forEach { identifier in
					innergroup.enter()

					HealthKitManager.shared.queryMostRecentEntry(identifier: identifier) { sample in
						if let quantitySample = sample as? HKQuantitySample {
							values.append(quantitySample)
						}
						innergroup.leave()
					}
				}

				innergroup.notify(queue: .main) {
					todayData[quantityType] = values
					topGroup.leave()
				}
			} else {
				topGroup.enter()
				HealthKitManager.shared.queryTodaySteps { (statistics) -> Void in
					if let statistics = statistics {
						todayData[quantityType] = [statistics]
					}
					topGroup.leave()
				}
			}
		}

		topGroup.notify(queue: .main) { [weak profileViewController] in
			profileViewController?.todayHKData = todayData
		}

		controller.getRangeData = { interval, start, end, completion in
			var chartData: [HealthKitQuantityType: [StatModel]] = [:]
			var goals: [HealthKitQuantityType: Int] = [:]
			let chartGroup = DispatchGroup()
			HealthKitQuantityType.allCases.forEach { quantityType in
				chartGroup.enter()
				let innergroup = DispatchGroup()
				var values: [StatModel] = []
				quantityType.healthKitQuantityTypeIdentifiers.forEach { identifier in
					innergroup.enter()
					HealthKitManager.shared.queryData(identifier: identifier, startDate: start, endDate: end, intervalType: interval) { dataPoints in
						let stat = StatModel(type: quantityType, dataPoints: dataPoints)
						values.append(stat)
						innergroup.leave()
					}
				}

				innergroup.notify(queue: .main) {
					chartData[quantityType] = values
					goals[quantityType] = ProfileHelper.getGoal(for: quantityType)
					chartGroup.leave()
				}
			}

			chartGroup.notify(queue: .main) {
				completion?(chartData, goals)
			}
		}

		controller.editButtonAction = { [weak self] _, _ in
			self?.gotoProfileEntryViewController()
		}

		navigate(to: controller, with: .push)
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

	internal func postGetData(search: SearchParameter, completion: @escaping (ModelsR4.Bundle?) -> Void) {}

	internal func postObservationSearchAction(search: SearchParameter, viewController: ProfileViewController, start: Date, end: Date, hkType: HealthKitQuantityType) {}

	internal func logout() {
		parentCoordinator?.logout()
	}

	deinit {
		navigationController?.viewControllers = []
		rootViewController?.dismiss(animated: true, completion: nil)
	}

	@objc internal func didTapSettings() {
		gotoSettings()
	}

	@objc internal func didTapProfileButton() {
		goToProfile()
	}

	@objc internal func backAction() {
		navigationController?.popViewController(animated: true)
	}

	@objc internal func addAction() {
		if let observation = observation {
			showHUD()
			APIClient.client.postObservation(observation: observation) { [weak self] result in
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
			APIClient.client.postBundle(bundle: bundle) { [weak self] result in
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
}

extension AppCoordinator: UINavigationControllerDelegate {
	func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
		if viewController is DailyTasksPageViewController {
			let profileButton = UIBarButtonItem(image: UIImage(named: "iconProfile")?.withRenderingMode(.alwaysTemplate), style: UIBarButtonItem.Style.plain, target: self, action: #selector(didTapProfileButton))
			profileButton.tintColor = UIColor.black
			viewController.navigationItem.setRightBarButton(profileButton, animated: true)
		} else if viewController is ProfileViewController || viewController is TroubleshootingViewController || viewController is TodayInputViewController {
			if viewController is ProfileViewController, viewController.navigationItem.rightBarButtonItem == nil {
				let settingsBtn = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(didTapSettings))
				settingsBtn.tintColor = .black
				viewController.navigationItem.setRightBarButton(settingsBtn, animated: true)
			} else if viewController is TodayInputViewController, viewController.navigationItem.rightBarButtonItem == nil {
				let addBtn = UIBarButtonItem(title: Str.add, style: UIBarButtonItem.Style.plain, target: self, action: #selector(addAction))
				addBtn.tintColor = UIColor.cursorOrange
				viewController.navigationItem.setRightBarButton(addBtn, animated: true)
			}
		}
	}
}
