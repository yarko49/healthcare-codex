//
//  CarePlanTasksViewController.swift
//  Alfred
//
//  Created by Waqar Malik on 1/7/21.
//

import CareKit
import CareKitStore
import CareKitUI
import SwiftUI
import UIKit

class CarePlanTasksViewController: OCKDailyTasksPageViewController {
	var carePlanStoreManager: CarePlanStoreManager {
		AppDelegate.appDelegate.carePlanStoreManager
	}

	var identifiers: [String] = []
	override func viewDidLoad() {
		super.viewDidLoad()

		title = NSLocalizedString("TASKS", comment: "Tasks")

		AlfredClient.client.getCarePlan { [weak self] result in
			switch result {
			case .failure(let error):
				ALog.error("\(error.localizedDescription)")
			case .success(let carePlans):
				self?.carePlanStoreManager.insert(carePlansResponse: carePlans, for: nil, completion: { insertResult in
					switch insertResult {
					case .failure(let error):
						ALog.error("\(error.errorDescription ?? error.localizedDescription)")
					case .success(let identifiers):
						self?.identifiers = identifiers
						self?.reload()
					}
				})
			}
		}
	}

	override func dailyPageViewController(_ dailyPageViewController: OCKDailyPageViewController, prepare listViewController: OCKListViewController, for date: Date) {
		var query = OCKTaskQuery(for: date)
		query.excludesTasksWithNoEvents = true
		storeManager.store.fetchAnyTasks(query: query, callbackQueue: .main) { result in
			switch result {
			case .failure(let error):
				ALog.error("Fetching tasks for carePlans \(error.localizedDescription)")
			case .success(let tasks):
				for task in tasks {
					guard let identifier = task.groupIdentifier, let taskType = GroupIdentifierType(rawValue: identifier) else {
						continue
					}
					let eventQuery = OCKEventQuery(for: date)
					switch taskType {
					case .link:
						guard let ockTask = task as? OCKTask, let linkItems = ockTask.linkItems, !linkItems.isEmpty else {
							continue
						}
						let view = LinkView(title: Text(task.title ?? NSLocalizedString("LINKS", comment: "Links")), links: linkItems)
						listViewController.appendViewController(view.formattedHostingController(), animated: true)

					case .checklist:
						let viewController = OCKChecklistTaskViewController(task: task, eventQuery: eventQuery, storeManager: self.storeManager)
						listViewController.appendViewController(viewController, animated: true)

					case .grid:
						let viewController = OCKGridTaskViewController(task: task, eventQuery: eventQuery, storeManager: self.storeManager)
						listViewController.appendViewController(viewController, animated: true)

					case .log:
						let viewController = OCKButtonLogTaskViewController(task: task, eventQuery: eventQuery, storeManager: self.storeManager)
						listViewController.appendViewController(viewController, animated: true)

					case .numericProgress:
						let view = NumericProgressTaskView(task: task, eventQuery: eventQuery, storeManager: self.storeManager)
							.padding([.vertical], 10)
						listViewController.appendViewController(view.formattedHostingController(), animated: true)

					case .labeledValue:
						let view = LabeledValueTaskView(task: task, eventQuery: eventQuery, storeManager: self.storeManager)
							.padding([.vertical], 10)
						listViewController.appendViewController(view.formattedHostingController(), animated: true)

					case .instruction:
						let viewController = OCKInstructionsTaskViewController(task: task, eventQuery: eventQuery, storeManager: self.storeManager)
						listViewController.appendViewController(viewController, animated: true)

					default:
						break
					}
				}
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
