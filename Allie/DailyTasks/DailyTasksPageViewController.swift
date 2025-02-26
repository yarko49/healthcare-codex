//
//  DailyTasksPageViewController.swift
//  Allie
//
//  Created by Waqar Malik on 1/7/21.
//

import CareKit
import CareKitStore
import CareKitUI
import Combine
import CoreBluetooth
import HealthKit
import JGProgressHUD
import SwiftUI
import UIKit

class DailyTasksPageViewController: OCKDailyTasksPageViewController {
	@Injected(\.careManager) var careManager: CareManager
	@Injected(\.healthKitManager) var healthKitManager: HealthKitManager
	@Injected(\.networkAPI) var networkAPI: AllieAPI
	@Injected(\.bluetoothManager) var bloodGlucoseMonitor: BGMBluetoothManager
	@Injected(\.remoteConfig) var remoteConfig: RemoteConfigManager

	var timerInterval: TimeInterval = 60 * 10
	let hud: JGProgressHUD = {
		let view = JGProgressHUD(style: .dark)
		view.vibrancyEnabled = true
		view.textLabel.text = NSLocalizedString("LOADING", comment: "Loading")
		view.detailTextLabel.text = NSLocalizedString("YOUR_CAREPLAN", comment: "Your Care Plan")
		return view
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		disableFutureTasks = true
		navigationItem.leftBarButtonItem = nil
		navigationItem.titleView = todayButton
		todayButton.addTarget(self, action: #selector(gotoToday(_:)), for: .touchDown)
		view.backgroundColor = .allieWhite
		NotificationCenter.default.publisher(for: .patientDidSnychronize)
			.receive(on: RunLoop.main)
			.sink { [weak self] _ in
				self?.reload()
			}.store(in: &cancellables)

		NotificationCenter.default.publisher(for: .didUpdateCarePlan)
			.receive(on: RunLoop.main)
			.sink { [weak self] _ in
				self?.reload()
			}.store(in: &cancellables)

		NotificationCenter.default.publisher(for: .didModifyHealthKitStore, object: nil)
			.receive(on: RunLoop.main, options: nil)
			.sink { [weak self] _ in
				self?.refresh()
			}.store(in: &cancellables)

		if careManager.patient?.bgmName == nil {
			NotificationCenter.default.publisher(for: .didPairBloodGlucoseMonitor)
				.receive(on: RunLoop.main)
				.sink { [weak self] _ in
					self?.startBluetooth()
				}.store(in: &cancellables)
		}

		Timer.publish(every: timerInterval, tolerance: 10.0, on: .current, in: .common, options: nil)
			.autoconnect()
			.receive(on: RunLoop.main)
			.sink(receiveValue: { [weak self] _ in
				self?.reload()
			}).store(in: &cancellables)

		careManager.startUploadOutcomesTimer(timeInterval: remoteConfig.outcomesUploadTimeInterval)
		healthKitManager.authorizeHealthKit { [weak self] success, error in
			if let error = error {
				ALog.error("Unable to authorize the HealthKit", error: error)
			} else {
				ALog.info("Success result \(success)")
			}
			DispatchQueue.main.async {
				self?.reload()
			}
			if self?.careManager.patient?.bgmName != nil {
				self?.startBluetooth()
			}
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		bloodGlucoseMonitor.multicastDelegate.add(self)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		AnalyticsManager.send(event: .pageView, properties: [.name: "CarePlanDailyTasks"])
	}

	deinit {
		bloodGlucoseMonitor.multicastDelegate.remove(self)
		cancellables.forEach { cancellable in
			cancellable.cancel()
		}
	}

	private let todayButton: UIButton = {
		let button = UIButton(type: .custom)
		button.setTitle(NSLocalizedString("TODAY", comment: "Today"), for: .normal)
		button.titleLabel?.font = UIFont.systemFont(ofSize: 17.0, weight: .semibold)
		button.setTitleColor(.allieBlack, for: .normal)
		return button
	}()

	var cancellables: Set<AnyCancellable> = []

	override func dailyPageViewController(_ dailyPageViewController: OCKDailyPageViewController, prepare listViewController: OCKListViewController, for date: Date) {
		var query = OCKTaskQuery(for: date)
		query.excludesTasksWithNoEvents = true
		storeManager.store.fetchAnyTasks(query: query, callbackQueue: .main) { [weak self] result in
			guard let self = self else {
				return
			}
			switch result {
			case .failure(let error):
				ALog.error("Fetching tasks for carePlans", error: error)
			case .success(let tasks):
				let filtered = tasks.filter { task in
					if let chTask = self.careManager.tasks[task.id] {
						return !chTask.isDeleted(for: date) && task.schedule.exists(onDay: date)
					} else if let ockTask = task as? OCKTask {
						return !ockTask.isDeleted(for: date) && task.schedule.exists(onDay: date)
					} else if let hkTask = task as? OCKHealthKitTask, let deletedDate = hkTask.deletedDate {
						return deletedDate.shouldShow(for: date)
					} else {
						return true
					}
				}

				let sorted = filtered.sorted { lhs, rhs in
					guard let left = lhs as? AnyTaskExtensible, let right = rhs as? AnyTaskExtensible else {
						return false
					}
					return left.priority < right.priority
				}

				for storeTask in sorted {
					guard let identifier = storeTask.groupIdentifier, let taskType = CHGroupIdentifierType(rawValue: identifier) else {
						continue
					}
					var task = storeTask
					if let chTask = self.careManager.tasks[task.id] {
						if let ockTask = task as? OCKTask {
							task = ockTask.updated(new: chTask)
						} else if let hkTask = task as? OCKHealthKitTask {
							task = hkTask.updated(new: chTask)
						}
					}
					let eventQuery = OCKEventQuery(for: date)
					switch taskType {
					case .simple:
						let viewController = SimpleTaskViewController(task: task, eventQuery: eventQuery, storeManager: self.storeManager)
						viewController.view.tintColor = .allieLighterGray
						listViewController.appendViewController(viewController, animated: self.insertViewsAnimated)

					case .link:
						guard let ockTask = task as? OCKTask, let linkItems = ockTask.linkItems, !linkItems.isEmpty else {
							continue
						}
						let view = LinkView(title: Text(task.title ?? NSLocalizedString("LINKS", comment: "Links")), links: linkItems)
							.accentColor(Color(.allieLighterGray))
						listViewController.appendViewController(view.formattedHostingController(), animated: self.insertViewsAnimated)

					case .checklist:
						let viewController = ChecklistTaskViewController(task: task, eventQuery: eventQuery, storeManager: self.storeManager)
						viewController.view.tintColor = .allieLighterGray
						listViewController.appendViewController(viewController, animated: self.insertViewsAnimated)

					case .grid:
						let viewController = GridTaskViewController(task: task, eventQuery: eventQuery, storeManager: self.storeManager)
						viewController.view.tintColor = .allieLighterGray
						listViewController.appendViewController(viewController, animated: self.insertViewsAnimated)

					case .log:
						let viewController = ButtonLogTaskViewController(task: task, eventQuery: eventQuery, storeManager: self.storeManager)
						viewController.view.tintColor = .allieGray
						listViewController.appendViewController(viewController, animated: self.insertViewsAnimated)

					case .logInsulin:
						let viewController = GeneralizedLogTaskViewController(task: task, eventQuery: eventQuery, storeManager: self.storeManager)
						viewController.view.tintColor = .allieGray
						viewController.controller.fetchAndObserveEvents(forTasks: [task], eventQuery: eventQuery)
						listViewController.appendViewController(viewController, animated: self.insertViewsAnimated)

					case .labeledValue:
						if (task as? OCKHealthKitTask)?.healthKitLinkage != nil {
							let viewController = GeneralizedLogTaskViewController(task: task, eventQuery: eventQuery, storeManager: self.storeManager)
							viewController.view.tintColor = .allieGray
							viewController.controller.fetchAndObserveEvents(forTasks: [task], eventQuery: eventQuery)
							listViewController.appendViewController(viewController, animated: self.insertViewsAnimated)
						} else {
							let view = LabeledValueTaskView(task: task, eventQuery: eventQuery, storeManager: self.storeManager)
								.accentColor(Color(.allieGray))
							listViewController.appendViewController(view.formattedHostingController(), animated: self.insertViewsAnimated)
						}
					case .numericProgress:
						if #available(iOS 15, *) {
							// There is a bug in iOS 15, with overlapping cards, so we disable until Apple fixes it
						} else {
							let view = NumericProgressTaskView(task: task, eventQuery: eventQuery, storeManager: self.storeManager)
							listViewController.appendViewController(view.formattedHostingController(), animated: self.insertViewsAnimated)
						}
					case .instruction:
						let viewController = OCKInstructionsTaskViewController(task: task, eventQuery: eventQuery, storeManager: self.storeManager)
						viewController.view.tintColor = .allieLighterGray
						listViewController.appendViewController(viewController, animated: self.insertViewsAnimated)

					case .featuredContent:
						let viewController = FeaturedContentViewController(task: task)
						viewController.view.tintColor = .allieLighterGray
						listViewController.appendViewController(viewController, animated: self.insertViewsAnimated)

					case .symptoms:
						let viewController = SymptomsLogViewController(task: task, eventQuery: eventQuery, storeManager: self.storeManager)
						viewController.view.tintColor = .allieGray
						viewController.controller.fetchAndObserveEvents(forTasks: [task], eventQuery: eventQuery)
						listViewController.appendViewController(viewController, animated: self.insertViewsAnimated)
					case .dexcom:
						break
					}
				}
			}
		}
	}

	func refresh() {
		insertViewsAnimated = false
		shouldUpdateCarePlan = false
		reload()
		shouldUpdateCarePlan = true
		insertViewsAnimated = true
	}

	private var insertViewsAnimated: Bool = true
	private var shouldUpdateCarePlan: Bool = true

	override func reload() {
		if shouldUpdateCarePlan {
			getAndUpdateCarePlans { _ in
				DispatchQueue.main.async {
					super.reload()
				}
			}
		} else {
			super.reload()
		}
	}

	private var isRefreshingCarePlan = false
	func getAndUpdateCarePlans(completion: @escaping AllieBoolCompletion) {
		guard isRefreshingCarePlan == false else {
			return
		}
		isRefreshingCarePlan = true
		hud.show(in: tabBarController?.view ?? view, animated: true)
		networkAPI.getCarePlan(option: .carePlan)
			.sink { [weak self] resultCompletion in
				self?.isRefreshingCarePlan = false
				self?.hud.dismiss(animated: true)
				if case .failure(let error) = resultCompletion {
					let nsError = error as NSError
					let codes: Set<Int> = [401, 408, -1001]
					if !codes.contains(nsError.code) {
						ALog.error("Unable to fetch care plan", error: error)
						let okAction = AlertHelper.AlertAction(withTitle: String.ok)
						let title = NSLocalizedString("ERROR", comment: "Error")
						AlertHelper.showAlert(title: title, detailText: error.localizedDescription, actions: [okAction], from: self?.tabBarController)
					}
					completion(false)
				}
			} receiveValue: { [weak self] value in
				if let tasks = value.faultyTasks, !tasks.isEmpty {
					self?.showError(tasks: tasks)
				}
				self?.careManager.process(carePlanResponse: value, forceReset: false) { result in
					switch result {
					case .failure(let error):
						ALog.error("Unable to update the careplan data", error: error)
						completion(false)
					case .success:
						ALog.info("added the care plan")
						completion(true)
					}
					self?.isRefreshingCarePlan = false
				}
			}.store(in: &cancellables)
	}

	func showError(tasks: [CHBasicTask]) {
		let viewController = TaskErrorDisplayViewController(style: .plain)
		viewController.items = tasks
		let navigationController = UINavigationController(rootViewController: viewController)
		tabBarController?.present(navigationController, animated: true, completion: nil)
	}

	@IBAction func gotoToday(_ sender: Any) {
		selectDate(Date(), animated: true)
	}
}

private extension View {
	func formattedHostingController() -> UIHostingController<Self> {
		let viewController = UIHostingController(rootView: self)
		viewController.view.backgroundColor = .clear
		return viewController
	}
}
