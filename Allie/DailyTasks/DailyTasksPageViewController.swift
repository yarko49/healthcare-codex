//
//  DailyTasksPageViewController.swift
//  Allie
//
//  Created by Waqar Malik on 1/7/21.
//

import BluetoothService
import CareKit
import CareKitStore
import CareKitUI
import CareModel
import CodexFoundation
import Combine
import CoreBluetooth
import Foundation
import HealthKit
import JGProgressHUD
import OmronKit
import SwiftUI
import UIKit

class DailyTasksPageViewController: OCKDailyTasksPageViewController {
	@Injected(\.careManager) var careManager: CareManager
	@Injected(\.healthKitManager) var healthKitManager: HealthKitManager
	@Injected(\.networkAPI) var networkAPI: AllieAPI
	@Injected(\.remoteConfig) var remoteConfig: RemoteConfigManager
	@Injected(\.syncManager) var syncManager: BluetoothSyncManager

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
		}
		syncManager.start()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		AnalyticsManager.send(event: .pageView, properties: [.name: "CarePlanDailyTasks"])
	}

	deinit {
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

	@MainActor
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
					var updatedTask = storeTask
					if let chTask = self.careManager.tasks[updatedTask.id] {
						if let ockTask = updatedTask as? OCKTask {
							updatedTask = ockTask.updated(new: chTask)
						} else if let hkTask = updatedTask as? OCKHealthKitTask {
							updatedTask = hkTask.updated(new: chTask)
						}
					}

					guard let taskType = updatedTask.groupIdentifierType else {
						continue
					}

					let eventQuery = OCKEventQuery(for: date)
					switch taskType {
					case .simple:
						let viewController = SimpleTaskViewController(task: updatedTask, eventQuery: eventQuery, storeManager: self.storeManager)
						viewController.view.tintColor = .allieLighterGray
						listViewController.appendViewController(viewController, animated: self.insertViewsAnimated)

					case .link:
						guard let ockTask = updatedTask as? OCKTask, let linkItems = ockTask.linkItems, !linkItems.isEmpty else {
							continue
						}
						let view = LinkView(title: Text(updatedTask.title ?? NSLocalizedString("LINKS", comment: "Links")), links: linkItems)
							.accentColor(Color(.allieLighterGray))
						listViewController.appendViewController(view.formattedHostingController(), animated: self.insertViewsAnimated)

					case .checklist:
						let viewController = ChecklistTaskViewController(task: updatedTask, eventQuery: eventQuery, storeManager: self.storeManager)
						viewController.view.tintColor = .allieLighterGray
						listViewController.appendViewController(viewController, animated: self.insertViewsAnimated)

					case .grid:
						let viewController = GridTaskViewController(task: updatedTask, eventQuery: eventQuery, storeManager: self.storeManager)
						viewController.view.tintColor = .allieLighterGray
						listViewController.appendViewController(viewController, animated: self.insertViewsAnimated)

					case .log:
						let viewController = ButtonLogTaskViewController(task: updatedTask, eventQuery: eventQuery, storeManager: self.storeManager)
						viewController.view.tintColor = .allieGray
						listViewController.appendViewController(viewController, animated: self.insertViewsAnimated)

					case .logInsulin:
						let viewController = GeneralizedLogTaskViewController(task: updatedTask, eventQuery: eventQuery, storeManager: self.storeManager)
						viewController.view.tintColor = .allieGray
						viewController.controller.fetchAndObserveEvents(forTasks: [updatedTask], eventQuery: eventQuery)
						listViewController.appendViewController(viewController, animated: self.insertViewsAnimated)

					case .labeledValue:
						if (updatedTask as? OCKHealthKitTask)?.healthKitLinkage != nil {
							let viewController = GeneralizedLogTaskViewController(task: updatedTask, eventQuery: eventQuery, storeManager: self.storeManager)
							viewController.view.tintColor = .allieGray
							viewController.controller.fetchAndObserveEvents(forTasks: [updatedTask], eventQuery: eventQuery)
							listViewController.appendViewController(viewController, animated: self.insertViewsAnimated)
						} else {
							let view = LabeledValueTaskView(task: updatedTask, eventQuery: eventQuery, storeManager: self.storeManager)
								.accentColor(Color(.allieGray))
							listViewController.appendViewController(view.formattedHostingController(), animated: self.insertViewsAnimated)
						}
					case .restingHeartRate:
						let view = LabeledValueTaskView(task: updatedTask, eventQuery: eventQuery, storeManager: self.storeManager)
							.accentColor(Color(.allieGray))
						listViewController.appendViewController(view.formattedHostingController(), animated: self.insertViewsAnimated)
					case .numericProgress:
						let view = NumericProgressTaskView(task: updatedTask, eventQuery: eventQuery, storeManager: self.storeManager)
						listViewController.appendViewController(view.iOS15FormattedHostingController(), animated: self.insertViewsAnimated)
					case .instruction:
						let viewController = OCKInstructionsTaskViewController(task: updatedTask, eventQuery: eventQuery, storeManager: self.storeManager)
						viewController.view.tintColor = .allieLighterGray
						listViewController.appendViewController(viewController, animated: self.insertViewsAnimated)

					case .featuredContent:
						let viewController = FeaturedContentViewController(task: updatedTask)
						viewController.view.tintColor = .allieLighterGray
						listViewController.appendViewController(viewController, animated: self.insertViewsAnimated)

					case .symptoms:
						let viewController = SymptomsLogViewController(task: updatedTask, eventQuery: eventQuery, storeManager: self.storeManager)
						viewController.view.tintColor = .allieGray
						viewController.controller.fetchAndObserveEvents(forTasks: [updatedTask], eventQuery: eventQuery)
						listViewController.appendViewController(viewController, animated: self.insertViewsAnimated)
					case .dexcom, .cgm, .irregularHeartRhythm:
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
		Task { [weak self] in
			do {
				let carePlanResponse = try await networkAPI.getCarePlan(option: .carePlan)
				if let tasks = carePlanResponse.faultyTasks, !tasks.isEmpty {
					self?.showError(tasks: tasks)
					return
				}
				careManager.process(carePlanResponse: carePlanResponse) { result in
					switch result {
					case .failure(let error):
						ALog.error("Error inserting care plan into db", error: error)
					case .success:
						ALog.info("Added new careplan to db")
					}
				}
				_ = try await careManager.process(newCarePlanResponse: carePlanResponse)
				self?.isRefreshingCarePlan = false
				self?.hud.dismiss(animated: true)
				completion(true)
			} catch {
				self?.isRefreshingCarePlan = false
				self?.hud.dismiss(animated: true)
				let nsError = error as NSError
				let codes: Set<Int> = [401, 404, 408, -1001]
				if !codes.contains(nsError.code) {
					ALog.error("Unable to fetch care plan", error: error)
					let okAction = AlertHelper.AlertAction(withTitle: String.ok)
					let title = NSLocalizedString("ERROR", comment: "Error")
					AlertHelper.showAlert(title: title, detailText: error.localizedDescription, actions: [okAction], from: self?.tabBarController)
				}
				completion(false)
			}
		}
	}

	@MainActor
	func showError(tasks: [CHBasicTask]) {
		let viewController = TaskErrorDisplayViewController(style: .plain)
		viewController.items = tasks
		let navigationController = UINavigationController(rootViewController: viewController)
		tabBarController?.present(navigationController, animated: true, completion: nil)
	}

	@MainActor
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

	func iOS15FormattedHostingController() -> UIHostingController<Self> {
		let viewController = HostingController(rootView: self)
		viewController.view.backgroundColor = .clear
		return viewController
	}
}

final class HostingController<Content: View>: UIHostingController<Content> {
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		view.setNeedsUpdateConstraints()
	}
}
