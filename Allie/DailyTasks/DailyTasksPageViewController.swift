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
import JGProgressHUD
import SwiftUI
import UIKit

class DailyTasksPageViewController: OCKDailyTasksPageViewController {
	var timerInterval: TimeInterval = 60 * 10

	private let hud: JGProgressHUD = {
		let view = JGProgressHUD(style: .dark)
		view.vibrancyEnabled = true
		view.textLabel.text = NSLocalizedString("LOADING", comment: "Loading")
		view.detailTextLabel.text = NSLocalizedString("YOUR_CAREPLAN", comment: "Your Care Plan")
		return view
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.leftBarButtonItem = nil
		navigationItem.titleView = todayButton
		todayButton.addTarget(self, action: #selector(gotoToday(_:)), for: .touchDown)
		view.backgroundColor = .allieWhite
		NotificationCenter.default.publisher(for: .patientDidSnychronize)
			.receive(on: DispatchQueue.main)
			.sink { [weak self] _ in
				self?.reload()
			}.store(in: &cancellables)

		Timer.publish(every: timerInterval, tolerance: 10.0, on: .current, in: .common, options: nil)
			.autoconnect()
			.receive(on: DispatchQueue.main)
			.sink { _ in
				ALog.info("Timer Fired")
			} receiveValue: { [weak self] _ in
				self?.reload()
			}
			.store(in: &cancellables)
		CareManager.shared.startUploadOutcomesTimer(timeInterval: RemoteConfigManager.shared.outcomesUploadTimeInterval)
		reload()
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

	private var cancellables: Set<AnyCancellable> = []
	private var insertViewsAnimated: Bool = false

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
				let sorted = tasks.sorted { lhs, rhs in
					guard let left = lhs as? AnyTaskExtensible, let right = rhs as? AnyTaskExtensible else {
						return false
					}
					return left.priority < right.priority
				}

				for task in sorted {
					guard let identifier = task.groupIdentifier, let taskType = CHGroupIdentifierType(rawValue: identifier) else {
						continue
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
						viewController.view.tintColor = .allieButtons
						listViewController.appendViewController(viewController, animated: self.insertViewsAnimated)

					case .logInsulin:
						let viewController = InsulinLogTaskViewController(task: task, eventQuery: eventQuery, storeManager: self.storeManager)
						viewController.view.tintColor = .allieButtons
						viewController.controller.fetchAndObserveEvents(forTaskIDs: [task.id], eventQuery: eventQuery)
						listViewController.appendViewController(viewController, animated: self.insertViewsAnimated)

					case .numericProgress:
						let view = NumericProgressTaskView(task: task, eventQuery: eventQuery, storeManager: self.storeManager)
						listViewController.appendViewController(view.formattedHostingController(), animated: self.insertViewsAnimated)

					case .labeledValue:
						let view = LabeledValueTaskView(task: task, eventQuery: eventQuery, storeManager: self.storeManager)
							.accentColor(Color(.allieButtons))
						listViewController.appendViewController(view.formattedHostingController(), animated: self.insertViewsAnimated)

					case .instruction:
						let viewController = OCKInstructionsTaskViewController(task: task, eventQuery: eventQuery, storeManager: self.storeManager)
						viewController.view.tintColor = .allieLighterGray
						listViewController.appendViewController(viewController, animated: self.insertViewsAnimated)

					case .featuredContent:
						let viewController = FeaturedContentViewController(task: task)
						viewController.view.tintColor = .allieLighterGray
						listViewController.appendViewController(viewController, animated: self.insertViewsAnimated)
					}
				}
			}
		}
	}

	private var isRefreshingCarePlan = false
	override func reload() {
		guard isRefreshingCarePlan == false else {
			return
		}
		isRefreshingCarePlan = true
		hud.show(in: tabBarController?.view ?? view, animated: true)
		APIClient.shared.getCarePlan(option: .carePlan)
			.sink { [weak self] completion in
				self?.isRefreshingCarePlan = false
				self?.hud.dismiss(animated: true)
				if case .failure(let error) = completion {
					let nsError = error as NSError
					if nsError.code != 401 {
						ALog.error("Unable to fetch care plan", error: error)
						let okAction = AlertHelper.AlertAction(withTitle: String.ok)
						AlertHelper.showAlert(title: "Error", detailText: error.localizedDescription, actions: [okAction])
					}
				}
			} receiveValue: { value in
				if let tasks = value.faultyTasks, !tasks.isEmpty {
					self.showError(tasks: tasks)
				}
				CareManager.shared.process(carePlanResponse: value, forceReset: false) { success in
					if success {
						ALog.info("added the care plan")
						DispatchQueue.main.async {
							super.reload()
						}
					} else {
						ALog.error("Unable to update the careplan data")
					}
					self.isRefreshingCarePlan = false
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
