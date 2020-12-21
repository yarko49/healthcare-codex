import HealthKit
import LocalAuthentication
import os.log
import UIKit

extension OSLog {
	static let mainCoordinator = OSLog(subsystem: subsystem, category: "MainAppCoordinator")
}

class MainAppCoordinator: NSObject, Coordinator, UIViewControllerTransitioningDelegate {
	internal var navigationController: UINavigationController?
	internal var childCoordinators: [CoordinatorKey: Coordinator]
	internal weak var parentCoordinator: MasterCoordinator?

	var context = LAContext()
	var error: NSError?

	var rootViewController: UIViewController? {
		navigationController
	}

	var observation: Resource?
	var bundle: BundleModel?
	var heightWeightBundle: BundleModel?
	var observationSearch: String?
	var observationSearchResult: BundleModel?
	var chartData: [Int] = []
	var dateData: [String] = []
	weak var profileVC: ProfileVC?

	init(with parent: MasterCoordinator?) {
		self.navigationController = HomeNC()
		self.parentCoordinator = parent
		self.childCoordinators = [:]
		super.init()
		navigationController?.delegate = self

		start()
	}

	internal func start() {
		if DataContext.shared.haveAskedUserforBiometrics() == false {
			enrollWithBiometrics()
		} else {
			if DataContext.shared.isBiometricsEnabled == false {}
		}
		showHome()
	}

	internal func evaluateBiometrics() {
		context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error)
		if context.biometryType == .none {
			os_log(.error, log: .mainCoordinator, "Error %@", error?.localizedDescription ?? "")
			return
		}
		os_log(.info, log: .mainCoordinator, "%@", String(describing: context.biometryType.rawValue))
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
			let biometricType = self.context.biometryType == .faceID ? Str.faceID : Str.touchID
			AlertHelper.showAlert(title: Str.automaticSignIn, detailText: Str.enroll(biometricType), actions: [okAction, noAction])
		}
	}

	internal func showHome() {
		let homeVC = HomeVC()

		let getCardsAction: (() -> Void)? = {
			AlertHelper.showLoader()
			DataContext.shared.getNotifications { notificationList in
				AlertHelper.hideLoader()
				homeVC.setupCards(with: notificationList)
			}
			DispatchQueue.main.async {
				homeVC.refreshControl.endRefreshing()
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

		homeVC.getCardsAction = getCardsAction
		homeVC.questionnaireAction = questionnaireAction
		homeVC.measurementCellAction = measurementCellAction
		homeVC.troubleshootingAction = troubleshootingAction
		navigate(to: homeVC, with: .push)
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
		let troubleshootingVC = TroubleshootingVC()

		troubleshootingVC.titleText = title ?? ""
		troubleshootingVC.previewTitle = previewTitle ?? ""
		troubleshootingVC.text = text ?? ""

		navigate(to: troubleshootingVC, with: .push)
	}

	internal func goToInput(with type: InputType) {
		let todayInputVC = TodayInputVC()
		todayInputVC.inputType = type
		let inputAction: ((Int?, Int?, String?, InputType) -> Void)? = { [weak self] value1, value2, effectiveDateTime, inputType in

			switch inputType {
			case .bloodPressure:
				let sysComponent = Component(code: DataContext.shared.systolicBPCode, valueQuantity: ValueQuantity(value: value1, unit: Str.pressureUnit))
				let diaComponent = Component(code: DataContext.shared.diastolicBPCode, valueQuantity: ValueQuantity(value: value2, unit: Str.pressureUnit))
				let observation = Resource(code: DataContext.shared.bpCode, effectiveDateTime: effectiveDateTime, id: nil, identifier: nil, meta: nil, resourceType: "Observation", status: "final", subject: Subject(reference: DataContext.shared.getPatientID(), type: "Patient", identifier: nil, display: DataContext.shared.getDisplayName()), valueQuantity: nil, birthDate: nil, gender: nil, name: nil, component: [sysComponent, diaComponent])
				self?.observation = observation
				self?.bundle = nil
			case .weight:
				let weightEntry = Entry(fullURL: nil, resource: Resource(code: DataContext.shared.weightCode, effectiveDateTime: effectiveDateTime, id: nil, identifier: nil, meta: nil, resourceType: "Observation", status: "final", subject: Subject(reference: DataContext.shared.getPatientID(), type: "Patient", identifier: nil, display: DataContext.shared.getDisplayName()), valueQuantity: ValueQuantity(value: value1, unit: Str.weightUnit), birthDate: nil, gender: nil, name: nil, component: nil), request: BERequest(method: "POST", url: "Observation"), search: nil, response: nil)
				let goalWeightEntry = Entry(fullURL: nil, resource: Resource(code: DataContext.shared.idealWeightCode, effectiveDateTime: effectiveDateTime, id: nil, identifier: nil, meta: nil, resourceType: "Observation", status: "final", subject: Subject(reference: DataContext.shared.getPatientID(), type: "Patient", identifier: nil, display: DataContext.shared.getDisplayName()), valueQuantity: ValueQuantity(value: value2, unit: Str.weightUnit), birthDate: nil, gender: nil, name: nil, component: nil), request: BERequest(method: "POST", url: "Observation"), search: nil, response: nil)

				let bundle = BundleModel(entry: [weightEntry, goalWeightEntry], link: nil, resourceType: "Bundle", total: nil, type: "transaction")
				self?.observation = nil
				self?.bundle = bundle
			}
		}
		todayInputVC.inputAction = inputAction
		navigate(to: todayInputVC, with: .push)
	}

	internal func goToProfile() {
		DataContext.shared.weightArray = []
		DataContext.shared.heightArray = []

		let profileVC = ProfileVC()
		self.profileVC = profileVC

		profileVC.getData = { [weak self] in
			AlertHelper.showLoader()
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
				self?.profileVC?.weight = weight
				self?.profileVC?.height = height
				self?.profileVC?.createDetailsLabel()
			}
			self?.profileVC?.patientTrendsTV.reloadData()
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

		topGroup.notify(queue: .main) { [weak profileVC] in
			profileVC?.todayHKData = todayData
		}

		profileVC.getRangeData = { interval, start, end, completion in
			var chartData: [HealthKitQuantityType: [StatModel]] = [:]
			var goals: [HealthKitQuantityType: Double] = [:]
			AlertHelper.showLoader()
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
				AlertHelper.hideLoader()
				completion?(chartData, goals)
			}
		}

		profileVC.editBtnAction = { [weak self] weight, height in
			self?.goToMyProfileFirstVC(source: .profile, weight: weight, height: height)
		}

		profileVC.backBtnAction = { [weak self] in
			self?.navigationController?.popViewController(animated: true)
		}
		navigate(to: profileVC, with: .push)
	}

	internal func postGetData(search: SearchParameter, completion: @escaping (BundleModel?) -> Void) {
		AlertHelper.showLoader()
		DataContext.shared.postObservationSearch(search: search) { response in
			AlertHelper.hideLoader()
			if response != nil {
				DataContext.shared.dataModel = response
				completion(response)
			}
		}
	}

	internal func postObservationSearchAction(search: SearchParameter, vc: ProfileVC, start: Date, end: Date, hkType: HealthKitQuantityType) {
		AlertHelper.showLoader()
		DataContext.shared.postObservationSearch(search: search) { response in
			AlertHelper.hideLoader()
			if response != nil {
			} else {
				os_log(.error, log: .mainCoordinator, "post Observation Search request failed")
			}
		}
	}

	internal func goToMyProfileFirstVC(source: ComingFrom = .profile, weight: Int, height: Int) {
		let myProfileFirstVC = MyProfileFirstVC()
		myProfileFirstVC.comingFrom = source
		myProfileFirstVC.firstText = DataContext.shared.getDisplayFirstName()
		myProfileFirstVC.lastText = DataContext.shared.getDisplayLastName()
		myProfileFirstVC.gender = DataContext.shared.getGender()

		myProfileFirstVC.backBtnAction = { [weak self] in
			self?.navigationController?.popViewController(animated: true)
		}

		let sendDataAction: ((String, String, [String]) -> Void)? = { [weak self] gender, family, given in
			self?.goToMyProfileSecondVC(gender: gender, family: family, given: given, source: source, weight: weight, height: height)
		}

		myProfileFirstVC.alertAction = { [weak self] tv in
			let okAction = AlertHelper.AlertAction(withTitle: Str.ok) {
				tv?.focus()
			}
			self?.showAlert(title: Str.invalidText, detailText: Str.invalidTextMsg, actions: [okAction])
		}

		myProfileFirstVC.sendDataAction = sendDataAction
		navigate(to: myProfileFirstVC, with: .push)
	}

	internal func goToMyProfileSecondVC(gender: String, family: String, given: [String], source: ComingFrom = .profile, weight: Int, height: Int) {
		let myProfileSecondVC = MyProfileSecondVC()
		myProfileSecondVC.comingFrom = source
		myProfileSecondVC.profileWeight = weight
		myProfileSecondVC.profileHeight = height

		myProfileSecondVC.backBtnAction = { [weak self] in
			self?.navigationController?.popViewController(animated: true)
		}

		myProfileSecondVC.patientRequestAction = { [weak self] _, birthdate, weight, height, date in
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
					os_log(.info, log: .masterCoordinator, "removing: %@, %ld", currentNames[index], index)
					patientUpdate.append(UpdatePatientModel(op: "remove", path: "/name/0/given/\(given.count)", value: nil))
				}
			}
			patientUpdate.append(UpdatePatientModel(op: "replace", path: "/gender", value: gender))
			DataContext.shared.editPatient = patientUpdate

			DataContext.shared.userModel?.dob = birthdate
			let name = [Name(use: "official", family: family, given: given)]
			DataContext.shared.userModel?.name = name
			DataContext.shared.userModel?.gender = Gender(rawValue: gender)
			let defaultPatient = [UpdatePatientModel(op: "", path: "", value: "")]
			let patient = DataContext.shared.editPatient
			self?.patientAPI(patient: patient ?? defaultPatient, weight: weight, height: height, date: date, birthDay: birthdate, family: family, given: given)
		}

		myProfileSecondVC.alertAction = { [weak self] _ in
			let okAction = AlertHelper.AlertAction(withTitle: Str.ok) {}
			self?.showAlert(title: Str.invalidInput, detailText: Str.emptyPickerField, actions: [okAction])
		}
		navigate(to: myProfileSecondVC, with: .push)
	}

	internal func patientAPI(patient: [UpdatePatientModel], weight: Int, height: Int, date: String, birthDay: String, family: String, given: [String]) {
		AlertHelper.showLoader()
		DataContext.shared.patchPatient(patient: patient) { [weak self] resourceResponse in
			AlertHelper.hideLoader()
			DataContext.shared.editPatient = patient
			if resourceResponse != nil {
				os_log(.info, log: .masterCoordinator, "OK STATUS FOR UPDATE PATIENT : 200")
				DataContext.shared.userModel = UserModel(userID: DataContext.shared.userModel?.userID ?? "", email: DataContext.shared.userModel?.email, name: [Name(use: "", family: family, given: given)], dob: birthDay, gender: DataContext.shared.userModel?.gender ?? Gender(rawValue: "female"))
				self?.profileVC?.nameLbl?.attributedText = ProfileHelper.getFirstName().with(style: .bold28, andColor: .black, andLetterSpacing: 0.36)
				self?.getHeightWeight(weight: weight, height: height, date: date)
			} else {
				os_log(.error, log: .masterCoordinator, "request failed")
				AlertHelper.showAlert(title: Str.error, detailText: Str.createPatientFailed, actions: [AlertHelper.AlertAction(withTitle: Str.ok)])
				return
			}
		}
	}

	internal func getHeightWeight(weight: Int, height: Int, date: String) {
		let displayName = DataContext.shared.getDisplayName()
		let referenceId = "Patient/\(DataContext.shared.userModel?.userID ?? "")"

		let weightObservation = Resource(code: DataContext.shared.weightCode, effectiveDateTime: date, id: nil, identifier: nil, meta: nil, resourceType: "Observation", status: "final", subject: Subject(reference: referenceId, type: "Patient", identifier: nil, display: displayName), valueQuantity: ValueQuantity(value: weight, unit: Str.weightUnit), birthDate: nil, gender: nil, name: nil, component: nil)

		let weightEntry = Entry(fullURL: nil, resource: weightObservation, request: BERequest(method: "POST", url: "Observation"), search: nil, response: nil)

		let heightObservation = Resource(code: DataContext.shared.heightCode, effectiveDateTime: date, id: nil, identifier: nil, meta: nil, resourceType: "Observation", status: "final", subject: Subject(reference: referenceId, type: "Patient", identifier: nil, display: displayName), valueQuantity: ValueQuantity(value: height, unit: Str.heightUnit), birthDate: nil, gender: nil, name: nil, component: nil)

		let heightEntry = Entry(fullURL: nil, resource: heightObservation, request: BERequest(method: "POST", url: "Observation"), search: nil, response: nil)
		let bundle = BundleModel(entry: [weightEntry, heightEntry], link: nil, resourceType: "Bundle", total: nil, type: "transaction")

		bundleAction(bundle: bundle)
	}

	internal func bundleAction(bundle: BundleModel) {
		AlertHelper.showLoader()
		DataContext.shared.postBundle(bundle: bundle) { [weak self] response in
			AlertHelper.hideLoader()
			if response != nil {
				self?.heightWeightBundle = bundle
				if let profile = self?.profileVC {
					self?.navigationController?.popToViewController(profile, animated: true)
				}
			} else {
				AlertHelper.hideLoader()
				os_log(.error, log: .masterCoordinator, "request failed")
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

	@objc internal func didTapProfileBtn() {
		goToProfile()
	}

	@objc internal func backAction() {
		navigationController?.popViewController(animated: true)
	}

	@objc internal func addAction() {
		if let observation = observation {
			AlertHelper.showLoader()
			DataContext.shared.postObservation(observation: observation) { [weak self] response in
				AlertHelper.hideLoader()
				if response != nil {
					self?.observation = nil
					self?.navigationController?.popViewController(animated: true)
				}
			}
		} else if let bundle = bundle {
			AlertHelper.showLoader()
			DataContext.shared.postBundle(bundle: bundle) { [weak self] response in
				AlertHelper.hideLoader()
				if response != nil {
					self?.bundle = nil
					self?.navigationController?.popViewController(animated: true)
				}
			}
		}
	}
}

extension MainAppCoordinator: UINavigationControllerDelegate {
	func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
		if viewController is HomeVC {
			if viewController.navigationItem.leftBarButtonItem == nil {
				let profileBtn = UIBarButtonItem(image: UIImage(named: "iconProfile")?.withRenderingMode(.alwaysTemplate), style: UIBarButtonItem.Style.plain, target: self, action: #selector(didTapProfileBtn))
				profileBtn.tintColor = UIColor.black
				viewController.navigationItem.setLeftBarButton(profileBtn, animated: true)
			}

		} else if viewController is ProfileVC || viewController is TroubleshootingVC || viewController is TodayInputVC {
			if viewController is ProfileVC, viewController.navigationItem.rightBarButtonItem == nil {
				let settingsBtn = UIBarButtonItem(image: UIImage(named: "gear")?.withRenderingMode(.alwaysTemplate), style: UIBarButtonItem.Style.plain, target: self, action: #selector(didTapSettings))
				settingsBtn.tintColor = .black
				viewController.navigationItem.setRightBarButton(settingsBtn, animated: true)
			} else if viewController is TodayInputVC, viewController.navigationItem.rightBarButtonItem == nil {
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
