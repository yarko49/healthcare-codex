import CareKitStore
import HealthKit
import LocalAuthentication
import ModelsR4
import UIKit

class MainAppCoordinator: NSObject, Coordinable, UIViewControllerTransitioningDelegate {
	let type: CoordinatorType = .mainAppCoordinator

	internal var navigationController: UINavigationController?
	internal var childCoordinators: [CoordinatorType: Coordinable]
	internal weak var parentCoordinator: MasterCoordinator?

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

	init(with parent: MasterCoordinator?) {
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

	internal func goToQuestionnaire() {
		let questionnaireCoord = QuestionnaireCoordinator(with: self)
		addChild(coordinator: questionnaireCoord)
		questionnaireCoord.start()
	}

	internal func goToTroubleshooting(previewTitle: String?, title: String?, text: String?, icon: IconType?) {
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
		DataContext.shared.weightArray = []
		DataContext.shared.heightArray = []

		let controller = ProfileViewController()
		profileViewController = controller

		controller.getData = { [weak self] in
			AppDelegate.careManager.loadPatient { result in
				switch result {
				case .failure(let error):
					ALog.error("\(error.localizedDescription)")
				case .success(let patient):
					self?.profileViewController?.weight = patient.weight
					self?.profileViewController?.height = patient.height
					self?.profileViewController?.createDetailsLabel()
				}
			}
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
			var goals: [HealthKitQuantityType: Double] = [:]
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

		controller.editButtonAction = { [weak self] weight, height in
			self?.goToMyProfileFirstViewController(source: .profile, weight: weight, height: height)
		}

		navigate(to: controller, with: .push)
	}

	internal func postGetData(search: SearchParameter, completion: @escaping (CodexBundle?) -> Void) {
		APIClient.client.postObservationSearch(search: search) { result in
			switch result {
			case .success(let response):
				completion(response)
			case .failure(let error):
				ALog.error("Post GetData", error: error)
				completion(nil)
			}
		}
	}

	internal func postObservationSearchAction(search: SearchParameter, viewController: ProfileViewController, start: Date, end: Date, hkType: HealthKitQuantityType) {
		APIClient.client.postObservationSearch(search: search) { result in
			switch result {
			case .success:
				ALog.info("Post Observation Search Action")
			case .failure(let error):
				ALog.error("Post Observation Search Action", error: error)
			}
		}
	}

	internal func goToMyProfileFirstViewController(source: NavigationSourceType = .profile, weight: Int, height: Int) {
		let myProfileFirstViewController = MyProfileFirstViewController()
		let patient = AppDelegate.careManager.patient
		myProfileFirstViewController.comingFrom = source
		myProfileFirstViewController.firstText = patient?.name.givenName ?? ""
		myProfileFirstViewController.lastText = patient?.name.familyName ?? ""
		myProfileFirstViewController.gender = patient?.sex

		let sendDataAction: ((OCKBiologicalSex, String, [String]) -> Void)? = { [weak self] gender, family, given in
			self?.goToMyProfileSecondViewController(gender: gender, family: family, given: given, source: source, weight: weight, height: height)
		}

		myProfileFirstViewController.alertAction = { [weak self] tv in
			let okAction = AlertHelper.AlertAction(withTitle: Str.ok) {
				tv?.focus()
			}
			self?.showAlert(title: Str.invalidText, detailText: Str.invalidTextMsg, actions: [okAction])
		}

		myProfileFirstViewController.sendDataAction = sendDataAction
		navigate(to: myProfileFirstViewController, with: .push)
	}

	internal func goToMyProfileSecondViewController(gender: OCKBiologicalSex, family: String, given: [String], source: NavigationSourceType = .profile, weight: Int, height: Int) {
		let myProfileSecondViewController = MyProfileSecondViewController()
		myProfileSecondViewController.comingFrom = source
		myProfileSecondViewController.profileWeight = weight
		myProfileSecondViewController.profileHeight = height

		myProfileSecondViewController.patientRequestAction = { [weak self] _, birthdate, weight, height, date in
			var patient = AppDelegate.careManager.patient
			var givenNames = given
			patient?.name.givenName = givenNames.first
			givenNames.removeFirst()
			patient?.name.middleName = givenNames.joined(separator: " ")
			patient?.name.familyName = family
			patient?.sex = gender
			patient?.effectiveDate = date
			patient?.birthday = birthdate
			patient?.weight = weight
			patient?.height = height
			AppDelegate.careManager.createOrUpdate(patient: patient!) { [weak self] _ in
				self?.parentCoordinator?.uploadPatient(patient: patient!)
			}
		}

		myProfileSecondViewController.alertAction = { [weak self] _ in
			let okAction = AlertHelper.AlertAction(withTitle: Str.ok) {}
			self?.showAlert(title: Str.invalidInput, detailText: Str.emptyPickerField, actions: [okAction])
		}
		navigate(to: myProfileSecondViewController, with: .push)
	}

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

extension MainAppCoordinator: UINavigationControllerDelegate {
	func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
		if viewController is DailyTasksPageViewController {
			let profileButton = UIBarButtonItem(image: UIImage(named: "iconProfile")?.withRenderingMode(.alwaysTemplate), style: UIBarButtonItem.Style.plain, target: self, action: #selector(didTapProfileButton))
			profileButton.tintColor = UIColor.black
			viewController.navigationItem.setRightBarButton(profileButton, animated: true)
		} else if viewController is HomeViewController {
			if viewController.navigationItem.leftBarButtonItem == nil {
				let profileBtn = UIBarButtonItem(image: UIImage(named: "iconProfile")?.withRenderingMode(.alwaysTemplate), style: UIBarButtonItem.Style.plain, target: self, action: #selector(didTapProfileButton))
				profileBtn.tintColor = UIColor.black
				viewController.navigationItem.setLeftBarButton(profileBtn, animated: true)
			}
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
