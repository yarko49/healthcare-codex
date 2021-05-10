//
//  InsulinLogTaskViewController.swift
//  Allie
//
//  Created by Waqar Malik on 5/9/21.
//

import CareKit
import CareKitStore
import UIKit

class InsulinLogTaskViewController: OCKTaskViewController<InsulinLogTaskController, InsulinLogTaskViewSynchronizer> {
	var task: OCKHealthKitTask?

	override public init(controller: InsulinLogTaskController, viewSynchronizer: InsulinLogTaskViewSynchronizer) {
		super.init(controller: controller, viewSynchronizer: viewSynchronizer)
	}

	override public init(viewSynchronizer: InsulinLogTaskViewSynchronizer, task: OCKAnyTask, eventQuery: OCKEventQuery, storeManager: OCKSynchronizedStoreManager) {
		super.init(viewSynchronizer: viewSynchronizer, task: task, eventQuery: eventQuery, storeManager: storeManager)
	}

	override public init(viewSynchronizer: InsulinLogTaskViewSynchronizer, taskID: String, eventQuery: OCKEventQuery, storeManager: OCKSynchronizedStoreManager) {
		super.init(viewSynchronizer: viewSynchronizer, taskID: taskID, eventQuery: eventQuery, storeManager: storeManager)
	}

	public init(task: OCKAnyTask, eventQuery: OCKEventQuery, storeManager: OCKSynchronizedStoreManager) {
		super.init(viewSynchronizer: .init(), task: task, eventQuery: eventQuery, storeManager: storeManager)
		self.task = task as? OCKHealthKitTask
	}

	public init(taskID: String, eventQuery: OCKEventQuery, storeManager: OCKSynchronizedStoreManager) {
		super.init(viewSynchronizer: .init(), taskID: taskID, eventQuery: eventQuery, storeManager: storeManager)
	}
}
