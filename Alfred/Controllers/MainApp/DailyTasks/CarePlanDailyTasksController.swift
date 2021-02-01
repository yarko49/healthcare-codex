//
//  CarePlanDailyTasksController.swift
//  Alfred
//
//  Created by Waqar Malik on 1/7/21.
//

import CareKit
import CareKitStore
import CareKitUI
import JGProgressHUD
import SwiftUI
import UIKit

class CarePlanDailyTasksController: OCKDailyTasksPageViewController {
	var carePlanStoreManager: CarePlanStoreManager {
		AppDelegate.appDelegate.carePlanStoreManager
	}

	private let hud: JGProgressHUD = {
		let view = JGProgressHUD(style: .dark)
		view.vibrancyEnabled = true

		return view
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		title = NSLocalizedString("TASKS", comment: "Tasks")
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		fetchCarePlan()
		registerProvider()
	}

	var insertViewsAnimated: Bool = false

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
				for task in tasks {
					guard let identifier = task.groupIdentifier, let taskType = GroupIdentifierType(rawValue: identifier) else {
						continue
					}
					let eventQuery = OCKEventQuery(for: date)
					switch taskType {
					case .simple:
						let viewController = OCKSimpleTaskViewController(task: task, eventQuery: eventQuery, storeManager: self.storeManager)
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
}

private extension CarePlanDailyTasksController {
	func fetchCarePlan() {
		hud.show(in: navigationController?.view ?? view)
		CarePlanStoreManager.getCarePlan { [weak self] result in
			self?.hud.dismiss()
			switch result {
			case .failure(let error):
				ALog.error(error: error)
			case .success(let carePlans):
				self?.carePlanStoreManager.insert(carePlansResponse: carePlans, for: self?.carePlanStoreManager.patient, completion: { insertResult in
					switch insertResult {
					case .failure(let error):
						ALog.error(error: error)
					case .success:
						self?.reload()
						UserDefaults.standard.isCarePlanPopulated = true
					}
				})
			}
		}
	}

	func populateSamplePlan() {
		carePlanStoreManager.insert(carePlansResponse: CarePlanStoreManager.sampleResponse, for: carePlanStoreManager.patient) { _ in
			self.reload()
		}
	}
}

extension CarePlanDailyTasksController {
	func registerProvider() {
		let provider = "CodexPilotHealthcareOrganization"
		AlfredClient.client.registerProvider(identifier: provider) { result in
			switch result {
			case .failure(let error):
				ALog.error("Unable to register healthcare provider \(error.localizedDescription)")
			case .success:
				ALog.info("Did Register the provider \(provider)")
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
