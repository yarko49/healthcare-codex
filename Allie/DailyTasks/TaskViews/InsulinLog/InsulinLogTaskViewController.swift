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
		let reason = insulinView.reason
		let entryDate = entryViews.entryDate

		let sample = HKDiscreteQuantitySample(insulinUnits: value, startDate: entryViews.entryDate, reason: insulinView.reason)
		HKHealthStore().save(sample) { _, error in
			if let error = error {
				ALog.error("Unable to save insulin values", error: error)
			}
		}
		let unit = HKUnit(from: "IU")
		var outcomeValue = OCKOutcomeValue(value, units: unit.unitString)
		outcomeValue.kind = reason.kind
		outcomeValue.createdDate = entryDate
		controller.append(outcomeValue: outcomeValue, at: eventIndexPath, completion: notifyDelegateAndResetViewOnError)
	}

	private func notifyDelegateAndResetViewOnError<Success, Error>(result: Result<Success, Error>) {
		if case .failure(let error) = result {
			if delegate == nil {
				ALog.error("A task error occurred, but no delegate was set to forward it to!", error: error)
			}
			delegate?.taskViewController(self, didEncounterError: error)
			controller.taskEvents = controller.taskEvents // triggers an update to the view
		}
	}
}
