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
	var careManager: CareManager {
		AppDelegate.careManager
	}

	private let hud: JGProgressHUD = {
		let view = JGProgressHUD(style: .dark)
		view.vibrancyEnabled = true

		return view
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		title = NSLocalizedString("TASKS", comment: "Tasks")
		refreshCarePlan()

		NotificationCenter.default.publisher(for: .patientDidSnychronize)
			.receive(on: DispatchQueue.main)
			.sink { [weak self] _ in
				self?.refreshCarePlan()
			}.store(in: &cancellables)

		Timer.publish(every: 10.0, tolerance: 2.0, on: .current, in: .common, options: nil)
			.sink { _ in
				ALog.info("Timer Fired")
			} receiveValue: { [weak self] _ in
				self?.refreshCarePlan()
			}
			.store(in: &cancellables)

		refreshCarePlan()
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

	var cancellables: Set<AnyCancellable> = []
	var insertViewsAnimated: Bool = false

	override func dailyPageViewController(_ dailyPageViewController: OCKDailyPageViewController, prepare listViewController: OCKListViewController, for date: Date) {
		let query = OCKTaskQuery(for: date)
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
					guard let identifier = task.groupIdentifier, let taskType = GroupIdentifierType(rawValue: identifier) else {
						continue
					}
					let eventQuery = OCKEventQuery(for: date)
					switch taskType {
					case .simple:
						let viewController = SimpleTaskViewController(task: task, eventQuery: eventQuery, storeManager: self.storeManager)
						listViewController.appendViewController(viewController, animated: self.insertViewsAnimated)

					case .link:
						guard let ockTask = task as? OCKTask, let linkItems = ockTask.linkItems, !linkItems.isEmpty else {
							continue
						}
						let view = LinkView(title: Text(task.title ?? NSLocalizedString("LINKS", comment: "Links")), links: linkItems)
						listViewController.appendViewController(view.formattedHostingController(), animated: self.insertViewsAnimated)

					case .checklist:
						let viewController = ChecklistTaskViewController(task: task, eventQuery: eventQuery, storeManager: self.storeManager)
						listViewController.appendViewController(viewController, animated: self.insertViewsAnimated)

					case .grid:
						let viewController = GridTaskViewController(task: task, eventQuery: eventQuery, storeManager: self.storeManager)
						listViewController.appendViewController(viewController, animated: self.insertViewsAnimated)

					case .log:
						let viewController = ButtonLogTaskViewController(task: task, eventQuery: eventQuery, storeManager: self.storeManager)
						listViewController.appendViewController(viewController, animated: self.insertViewsAnimated)

					case .numericProgress:
						let view = NumericProgressTaskView(task: task, eventQuery: eventQuery, storeManager: self.storeManager)
						listViewController.appendViewController(view.formattedHostingController(), animated: self.insertViewsAnimated)

					case .labeledValue:
						let view = LabeledValueTaskView(task: task, eventQuery: eventQuery, storeManager: self.storeManager)
						listViewController.appendViewController(view.formattedHostingController(), animated: self.insertViewsAnimated)

					case .instruction:
						let viewController = OCKInstructionsTaskViewController(task: task, eventQuery: eventQuery, storeManager: self.storeManager)
						listViewController.appendViewController(viewController, animated: self.insertViewsAnimated)

					case .featuredContent:
						let viewControler = FeaturedContentViewController(task: task)
						listViewController.appendViewController(viewControler, animated: self.insertViewsAnimated)
					}
				}
			}
		}
	}

	private var isRefreshingCarePlan = false
	func refreshCarePlan() {
		guard isRefreshingCarePlan == false else {
			return
		}
		isRefreshingCarePlan = true
		CareManager.getCarePlan { [weak self] result in
			self?.isRefreshingCarePlan = false
			switch result {
			case .failure(let error):
				ALog.error(error: error)
			case .success(let carePlans):
				self?.careManager.insert(carePlansResponse: carePlans, completion: { insertResult in
					switch insertResult {
					case .failure(let error):
						ALog.error(error: error)
					case .success:
						ALog.info("added the care plan")
						DispatchQueue.main.async {
							self?.reload()
						}
					}
				})
			}
		}
	}
}

private extension View {
	func formattedHostingController() -> UIHostingController<Self> {
		let viewController = UIHostingController(rootView: self)
		viewController.view.backgroundColor = .clear
		return viewController
	}
}
