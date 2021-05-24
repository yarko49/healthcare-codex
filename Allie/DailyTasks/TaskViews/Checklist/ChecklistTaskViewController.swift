//
//  ChecklistTaskViewController.swift
//  Allie
//
//  Created by Waqar Malik on 1/17/21.
//

import CareKit
import CareKitStore
import CareKitUI
import UIKit

class ChecklistTaskViewController: OCKTaskViewController<OCKChecklistTaskController, ChecklistTaskViewSynchronizer> {
	override public init(controller: OCKChecklistTaskController, viewSynchronizer: ChecklistTaskViewSynchronizer) {
		super.init(controller: controller, viewSynchronizer: viewSynchronizer)
	}

	override public init(viewSynchronizer: ChecklistTaskViewSynchronizer, task: OCKAnyTask, eventQuery: OCKEventQuery, storeManager: OCKSynchronizedStoreManager) {
		super.init(viewSynchronizer: viewSynchronizer, task: task, eventQuery: eventQuery, storeManager: storeManager)
	}

	override public init(viewSynchronizer: ChecklistTaskViewSynchronizer, taskID: String, eventQuery: OCKEventQuery, storeManager: OCKSynchronizedStoreManager) {
		super.init(viewSynchronizer: viewSynchronizer, taskID: taskID, eventQuery: eventQuery, storeManager: storeManager)
	}

	public init(task: OCKAnyTask, eventQuery: OCKEventQuery, storeManager: OCKSynchronizedStoreManager) {
		super.init(viewSynchronizer: .init(), task: task, eventQuery: eventQuery, storeManager: storeManager)
	}

	public init(taskID: String, eventQuery: OCKEventQuery, storeManager: OCKSynchronizedStoreManager) {
		super.init(viewSynchronizer: .init(), taskID: taskID, eventQuery: eventQuery, storeManager: storeManager)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		AnalyticsManager.send(event: .pageView, properties: [.name: "CheckListTaskView"])
	}

	override open func didSelectTaskView(_ taskView: UIView & OCKTaskDisplayable, eventIndexPath: IndexPath) {}
}
