//
//  InsulinLogTaskViewController.swift
//  Allie
//
//  Created by Waqar Malik on 5/9/21.
//

import CareKit
import CareKitStore
import CareKitUI
import Combine
import HealthKit
import UIKit

class InsulinLogTaskViewController: OCKTaskViewController<InsulinLogTaskController, InsulinLogTaskViewSynchronizer> {
	private var cancellables: Set<AnyCancellable> = []

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
		let synchronizer = InsulinLogTaskViewSynchronizer()
		super.init(viewSynchronizer: synchronizer, task: task, eventQuery: eventQuery, storeManager: storeManager)
	}

	public init(taskID: String, eventQuery: OCKEventQuery, storeManager: OCKSynchronizedStoreManager) {
		super.init(viewSynchronizer: .init(), taskID: taskID, eventQuery: eventQuery, storeManager: storeManager)
	}

	override open func didSelectTaskView(_ taskView: UIView & OCKTaskDisplayable, eventIndexPath: IndexPath) {}

	override open func taskView(_ taskView: UIView & OCKTaskDisplayable, didCreateOutcomeValueAt index: Int, eventIndexPath: IndexPath, sender: Any?) {
		guard let insulinView = taskView as? InsulinLogTaskView else {
			return
		}
		let entryViews = insulinView.entryViews
		guard let units = entryViews.units, !units.isEmpty, let value = Double(units) else {
			return
		}
		let sample = HKDiscreteQuantitySample(insulinUnits: value, startDate: entryViews.entryDate, reason: insulinView.reason)
		HKHealthStore().save(sample) { _, error in
			if let error = error {
				ALog.error("Unable to save insulin values", error: error)
			}
		}
	}
}
