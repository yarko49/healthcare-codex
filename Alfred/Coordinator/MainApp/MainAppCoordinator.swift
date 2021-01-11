import HealthKit
import LocalAuthentication
import UIKit

class MainAppCoordinator: NSObject, Coordinator, UIViewControllerTransitioningDelegate {
	internal var navigationController: UINavigationController?
	internal var childCoordinators: [CoordinatorKey: Coordinator]
	internal weak var parentCoordinator: MasterCoordinator?

	var laContext = LAContext()

	var rootViewController: UIViewController? {
		navigationController
	}

	var observation: CodexResource?
	var bundle: CodexBundle?
	var heightWeightBundle: CodexBundle?
	var observationSearch: String?
	var observationSearchResult: CodexBundle?
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
		if DataContext.shared.haveAskedUserforBiometrics == false {
			enrollWithBiometrics()
		} else {
			if DataContext.shared.isBiometricsEnabled == false {}
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
			ALog.error("Error \(theError?.localizedDescription ?? "")")
			return
		}
		ALog.info("\(String(describing: context.biometryType.rawValue))")
	}

	func enrollWithBiometrics() {
		evaluateBiometrics()
		let okAction = AlertHelper.AlertAction(withTitle: Str.ok) {
			DataContext.shared.isBiometricsEnabled = true
		}
		let noAction = AlertHelper.AlertAction(withTitle: Str.no) {
			DataContext.shared.isBiometricsEnabled = false
		}
		DispatchQueue.main.async {
			let biometricType = self.laContext.biometryType == .faceID ? Str.faceID : Str.touchID
			AlertHelper.showAlert(title: Str.automaticSignIn, detailText: Str.enroll(biometricType), actions: [okAction, noAction])
		}
	}

	internal func showDailyTasksView() {
		let tasksViewController = CarePlanTasksViewController(storeManager: AppDelegate.carePlanStoreManager.synchronizedStoreManager)
		navigate(to: tasksViewController, with: .push)
	}

	internal func showHome() {
		let homeViewController = HomeViewController()
		let getCardsAction: (() -> Void)? = { [weak self] in
			DispatchQueue.main.async {
				self?.showHUD()
				AlfredClient.client.getCardList { result in
					self?.hideHUD()
					var notificationsCards: [NotificationCard]?
					switch result {
					case .failure(let error):
						ALog.error("error Fetching notificiation \(error.localizedDescription)")
					case .success(let cardList):
						notificationsCards = cardList.notifications
					}
					homeViewController.setupCards(with: notificationsCards)
				}
				homeViewController.refreshControl.endRefreshing()
			}
		}

		let questionnaireAction: (() -> Void)? = { [weak self] in
			self?.goToQuestionnaire()
		}

		let measurementCellAction: ((InputType) -> Void)? = { [weak self] inputType in
			self?.goToInput(with: inputType)
		}

		let troubleshootingAction: ((String?, String?, String?, IconType?) -> Void)? = { [weak self] previewTitle, title, text, icon in
			self?.goToTroubleshooting(previewTitle: previewTitle, title: title, text: text, icon: icon)
		}

		homeViewController.getCardsAction = getCardsAction
		homeViewController.questionnaireAction = questionnaireAction
		homeViewController.measurementCellAction = measurementCellAction
		homeViewController.troubleshootingAction = troubleshootingAction
		navigate(to: homeViewController, with: .push)
	}

	internal func gotoSettings() {
		let settingsCoord = SettingsCoordinator(with: self)
		addChild(coordinator: settingsCoord, with: .settingsCoordinator)
		settingsCoord.start()
	}

	internal func goToQuestionnaire() {
		let questionnaireCoord = QuestionnaireCoordinator(with: self)
		addChild(coordinator: questionnaireCoord, with: .questionnaireCoordinator)
		questionnaireCoord.start()
	}

	internal func goToTroubleshooting(previewTitle: String?, title: String?, text: String?, icon: IconType?) {
		let troubleshootingViewController = TroubleshootingViewController()

		troubleshootingViewController.titleText = title ?? ""
		troubleshootingViewController.previewTitle = previewTitle ?? ""
		troubleshootingViewController.text = text ?? ""

		navigate(to: troubleshootingViewController, with: .push)
	}

	internal func goToInput(with type: InputType) {
		let todayInputViewController = TodayInputViewController()
		todayInputViewController.inputType = type
		let inputAction: ((Int?, Int?, String?, InputType) -> Void)? = { [weak self] value1, value2, effectiveDateTime, inputType in

			switch inputType {
			case .bloodPressure:
				let sysComponent = Component(code: DataContext.shared.systolicBPCode, valueQuantity: ValueQuantity(value: value1, unit: Str.pressureUnit))
				let diaComponent = Component(code: DataContext.shared.diastolicBPCode, valueQuantity: ValueQuantity(value: value2, unit: Str.pressureUnit))
				let observation = CodexResource(id: nil, code: DataContext.shared.bpCode, effectiveDateTime: effectiveDateTime, identifier: nil, meta: nil, resourceType: "Observation", status: "final", subject: Subject(reference: DataContext.shared.patientID, type: "Patient", identifier: nil, display: DataContext.shared.displayName), valueQuantity: nil, birthDate: nil, gender: nil, name: nil, component: [sysComponent, diaComponent])
				self?.observation = observation
				self?.bundle = nil
			case .weight:
				let weightEntry = BundleEntry(fullURL: nil, resource: CodexResource(id: nil, code: DataContext.shared.weightCode, effectiveDateTime: effectiveDateTime, identifier: nil, meta: nil, resourceType: "Observation", status: "final", subject: Subject(reference: DataContext.shared.patientID, type: "Patient", identifier: nil, display: DataContext.shared.displayName), valueQuantity: ValueQuantity(value: value1, unit: Str.weightUnit), birthDate: nil, gender: nil, name: nil, component: nil), request: BundleRequest(method: "POST", url: "Observation"), search: nil, response: nil)
				let goalWeightEntry = BundleEntry(fullURL: nil, resource: CodexResource(id: nil, code: DataContext.shared.idealWeightCode, effectiveDateTime: effectiveDateTime, identifier: nil, meta: nil, resourceType: "Observation", status: "final", subject: Subject(reference: DataContext.shared.patientID, type: "Patient", identifier: nil, display: DataContext.shared.displayName), valueQuantity: ValueQuantity(value: value2, unit: Str.weightUnit), birthDate: nil, gender: nil, name: nil, component: nil), request: BundleRequest(method: "POST", url: "Observation"), search: nil, response: nil)

				let bundle = CodexBundle(entry: [weightEntry, goalWeightEntry], link: nil, resourceType: "Bundle", total: nil, type: "transaction")
				self?.observation = nil
				self?.bundle = bundle
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
			self?.showHUD()
			let group = DispatchGroup()
			var weight: Int? = 0
			var height: Int? = 0
			let weightParam = SearchParameter(sort: "-date", count: 1, code: DataContext.shared.weightCode.coding?.first?.code)
			group.enter()
			self?.postGetData(search: weightParam, completion: { response in
				group.leave()
				weight = response?.entry?.first?.resource?.valueQuantity?.value
			})
			let heightParam = SearchParameter(sort: "-date", count: 1, code: DataContext.shared.heightCode.coding?.first?.code)
			group.enter()
			self?.postGetData(search: heightParam, completion: { response in
				group.leave()
				height = response?.entry?.first?.resource?.valueQuantity?.value
			})
			group.notify(queue: .main) { [weak self] in
				self?.hideHUD()
				self?.profileViewController?.weight = weight
				self?.profileViewController?.height = height
				self?.profileViewController?.createDetailsLabel()
			}
			self?.profileViewController?.patientTrendsTableView.reloadData()
		}

		var todayData: [HealthKitQuantityType: [Any]] = [:]
		let topGroup = DispatchGroup()
		DataContext.shared.userAuthorizedQuantities.forEach { quantityType in
			if quantityType != .activity {
				topGroup.enter()
				let innergroup = DispatchGroup()
				var values: [Any] = []
				quantityType.identifiers.forEach { identifier in
					innergroup.enter()

					HealthKitManager.shared.getMostRecentEntry(identifier: identifier) { sample in
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
				HealthKitManager.shared.getTodaySteps { (statistics) -> Void in
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
			DataContext.shared.userAuthorizedQuantities.forEach { quantityType in
				chartGroup.enter()
				let innergroup = DispatchGroup()
				var values: [StatModel] = []
				quantityType.identifiers.forEach { identifier in
					innergroup.enter()
					HealthKitManager.shared.getData(identifier: identifier, startDate: start, endDate: end, intervalType: interval) { dataPoints in
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

		controller.editBtnAction = { [weak self] weight, height in
			self?.goToMyProfileFirstViewController(source: .profile, weight: weight, height: height)
		}

		controller.backBtnAction = { [weak self] in
			self?.navigationController?.popViewController(animated: true)
		}
		navigate(to: controller, with: .push)
	}

	internal func postGetData(search: SearchParameter, completion: @escaping (CodexBundle?) -> Void) {
		AlfredClient.client.postObservationSearch(search: search) { result in
			switch result {
			case .success(let response):
				DataContext.shared.dataModel = response
				completion(response)
			case .failure(let error):
				ALog.error("Post GetData \(error.localizedDescription)")
				completion(nil)
			}
		}
	}

	internal func postObservationSearchAction(search: SearchParameter, viewController: ProfileViewController, start: Date, end: Date, hkType: HealthKitQuantityType) {
		AlfredClient.client.postObservationSearch(search: search) { result in
			switch result {
			case .success:
				ALog.info("Post Observation Search Action")
			case .failure(let error):
				ALog.error("Post Observation Search Action \(error.localizedDescription)")
			}
		}
	}

	internal func goToMyProfileFirstViewController(source: ComingFrom = .profile, weight: Int, height: Int) {
		let myProfileFirstViewController = MyProfileFirstViewController()
		myProfileFirstViewController.comingFrom = source
		myProfileFirstViewController.firstText = DataContext.shared.displayFirstName
		myProfileFirstViewController.lastText = DataContext.shared.displayLastName
		myProfileFirstViewController.gender = DataContext.shared.gender

		myProfileFirstViewController.backBtnAction = { [weak self] in
			self?.navigationController?.popViewController(animated: true)
		}

		let sendDataAction: ((String, String, [String]) -> Void)? = { [weak self] gender, family, given in
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

	internal func goToMyProfileSecondViewController(gender: String, family: String, given: [String], source: ComingFrom = .profile, weight: Int, height: Int) {
		let myProfileSecondViewController = MyProfileSecondViewController()
		myProfileSecondViewController.comingFrom = source
		myProfileSecondViewController.profileWeight = weight
		myProfileSecondViewController.profileHeight = height

		myProfileSecondViewController.backBtnAction = { [weak self] in
			self?.navigationController?.popViewController(animated: true)
		}

		myProfileSecondViewController.patientRequestAction = { [weak self] _, birthdate, weight, height, date in
			let joinedNames = given.joined(separator: " ")
			DataContext.shared.firstName = joinedNames
			var patientUpdate = [UpdatePatientModel(op: "replace", path: "/name/0/family", value: family), UpdatePatientModel(op: "replace", path: "/birthDate", value: birthdate)]
			let currentNames = DataContext.shared.userModel?.name?.first?.given ?? []
			given.enumerated().forEach {
				if $0.offset < currentNames.count {
					patientUpdate.append(UpdatePatientModel(op: "replace", path: "/name/0/given/\($0.offset)", value: given[$0.offset]))
				} else {
					patientUpdate.append(UpdatePatientModel(op: "add", path: "/name/0/given/\($0.offset)", value: given[$0.offset]))
				}
			}

			if currentNames.count > given.count {
				for index in given.count ... (currentNames.count - 1) {
					ALog.info("removing: \(currentNames[index]), \(index)")
					patientUpdate.append(UpdatePatientModel(op: "remove", path: "/name/0/given/\(given.count)", value: nil))
				}
			}
			patientUpdate.append(UpdatePatientModel(op: "replace", path: "/gender", value: gender))
			DataContext.shared.updatePatient = patientUpdate

			DataContext.shared.userModel?.dob = birthdate
			let name = [ResourceName(use: "official", family: family, given: given)]
			DataContext.shared.userModel?.name = name
			DataContext.shared.userModel?.gender = Gender(rawValue: gender)
			let defaultPatient = [UpdatePatientModel(op: "", path: "", value: "")]
			let patient = DataContext.shared.updatePatient
			self?.patientAPI(patient: patient ?? defaultPatient, weight: weight, height: height, date: date, birthDay: birthdate, family: family, given: given)
		}

		myProfileSecondViewController.alertAction = { [weak self] _ in
			let okAction = AlertHelper.AlertAction(withTitle: Str.ok) {}
			self?.showAlert(title: Str.invalidInput, detailText: Str.emptyPickerField, actions: [okAction])
		}
		navigate(to: myProfileSecondViewController, with: .push)
	}

	internal func patientAPI(patient: [UpdatePatientModel], weight: Int, height: Int, date: String, birthDay: String, family: String, given: [String]) {
		showHUD()
		AlfredClient.client.patchPatient(patient: patient) { [weak self] result in
			self?.hideHUD()
			DataContext.shared.updatePatient = patient
			switch result {
			case .success:
				ALog.info("OK STATUS FOR UPDATE PATIENT : 200")
				DataContext.shared.userModel = UserModel(userID: DataContext.shared.userModel?.userID ?? "", email: DataContext.shared.userModel?.email, name: [ResourceName(use: "", family: family, given: given)], dob: birthDay, gender: DataContext.shared.userModel?.gender ?? Gender(rawValue: "female"))
				self?.profileViewController?.nameLabel?.attributedText = ProfileHelper.firstName.with(style: .bold28, andColor: .black, andLetterSpacing: 0.36)
				self?.getHeightWeight(weight: weight, height: height, date: date)
			case .failure(let error):
				ALog.error("request failed \(error.localizedDescription)")
				AlertHelper.showAlert(title: Str.error, detailText: Str.createPatientFailed, actions: [AlertHelper.AlertAction(withTitle: Str.ok)])
			}
		}
	}

	internal func getHeightWeight(weight: Int, height: Int, date: String) {
		let displayName = DataContext.shared.displayName
		let referenceId = "Patient/\(DataContext.shared.userModel?.userID ?? "")"

		let weightObservation = CodexResource(id: nil, code: DataContext.shared.weightCode, effectiveDateTime: date, identifier: nil, meta: nil, resourceType: "Observation", status: "final", subject: Subject(reference: referenceId, type: "Patient", identifier: nil, display: displayName), valueQuantity: ValueQuantity(value: weight, unit: Str.weightUnit), birthDate: nil, gender: nil, name: nil, component: nil)

		let weightEntry = BundleEntry(fullURL: nil, resource: weightObservation, request: BundleRequest(method: "POST", url: "Observation"), search: nil, response: nil)

		let heightObservation = CodexResource(id: nil, code: DataContext.shared.heightCode, effectiveDateTime: date, identifier: nil, meta: nil, resourceType: "Observation", status: "final", subject: Subject(reference: referenceId, type: "Patient", identifier: nil, display: displayName), valueQuantity: ValueQuantity(value: height, unit: Str.heightUnit), birthDate: nil, gender: nil, name: nil, component: nil)

		let heightEntry = BundleEntry(fullURL: nil, resource: heightObservation, request: BundleRequest(method: "POST", url: "Observation"), search: nil, response: nil)
		let bundle = CodexBundle(entry: [weightEntry, heightEntry], link: nil, resourceType: "Bundle", total: nil, type: "transaction")

		bundleAction(bundle: bundle)
	}

	internal func bundleAction(bundle: CodexBundle) {
		showHUD()
		AlfredClient.client.postBundle(bundle: bundle) { [weak self] result in
			self?.hideHUD()
			switch result {
			case .success:
				self?.heightWeightBundle = bundle
				if let profile = self?.profileViewController {
					self?.navigationController?.popToViewController(profile, animated: true)
				}
			case .failure(let error):
				ALog.error("request failed \(error.localizedDescription)")
				AlertHelper.showAlert(title: Str.error, detailText: Str.createBundleFailed, actions: [AlertHelper.AlertAction(withTitle: Str.ok)])
			}
		}
	}

	internal func logout() {
		DataContext.shared.removeBiometrics()
		parentCoordinator?.goToAuth()
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
			AlfredClient.client.postObservation(observation: observation) { [weak self] result in
				self?.hideHUD()
				switch result {
				case .failure(let error):
					ALog.error("Error posting Observation \(error.localizedDescription)")
				case .success:
					self?.observation = nil
					self?.navigationController?.popViewController(animated: true)
				}
			}
		} else if let bundle = bundle {
			showHUD()
			AlfredClient.client.postBundle(bundle: bundle) { [weak self] result in
				self?.hideHUD()
				switch result {
				case .failure(let error):
					ALog.error("Error posting Bundle \(error.localizedDescription)")
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
		if viewController is CarePlanTasksViewController {
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
				let settingsBtn = UIBarButtonItem(image: UIImage(named: "gear")?.withRenderingMode(.alwaysTemplate), style: UIBarButtonItem.Style.plain, target: self, action: #selector(didTapSettings))
				settingsBtn.tintColor = .black
				viewController.navigationItem.setRightBarButton(settingsBtn, animated: true)
			} else if viewController is TodayInputViewController, viewController.navigationItem.rightBarButtonItem == nil {
				let addBtn = UIBarButtonItem(title: Str.add, style: UIBarButtonItem.Style.plain, target: self, action: #selector(addAction))
				addBtn.tintColor = UIColor.cursorOrange
				viewController.navigationItem.setRightBarButton(addBtn, animated: true)
			}
			if viewController.navigationItem.leftBarButtonItem == nil {
				let backBtn = UIBarButtonItem(image: UIImage(named: "back")?.withRenderingMode(.alwaysTemplate), style: UIBarButtonItem.Style.plain, target: self, action: #selector(backAction))
				backBtn.tintColor = .black
				viewController.navigationItem.setLeftBarButton(backBtn, animated: true)
			}
		}
	}
}
