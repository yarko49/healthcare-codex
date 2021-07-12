//
//  GeneralizedLogTaskViewController.swift
//  Allie
//
//  Created by Waqar Malik on 7/10/21.
//

import CareKit
import CareKitStore
import CareKitUI
import Combine
import HealthKit
import UIKit

protocol GeneralizedLogTaskViewControllerDelegate: AnyObject {
	func generalizedLogTaskViewController(_ controller: GeneralizedLogTaskViewController, didSelectAddOutcome task: OCKHealthKitTask?)
}

class GeneralizedLogTaskViewController: OCKTaskViewController<GeneralizedLogTaskController, GeneralizedLogTaskViewSynchronizer> {
	private var cancellables: Set<AnyCancellable> = []
	var healthKitTask: OCKHealthKitTask?
	weak var logDelegate: GeneralizedLogTaskViewControllerDelegate?

	override public init(controller: GeneralizedLogTaskController, viewSynchronizer: GeneralizedLogTaskViewSynchronizer) {
		super.init(controller: controller, viewSynchronizer: viewSynchronizer)
	}

	override public init(viewSynchronizer: GeneralizedLogTaskViewSynchronizer, task: OCKAnyTask, eventQuery: OCKEventQuery, storeManager: OCKSynchronizedStoreManager) {
		super.init(viewSynchronizer: viewSynchronizer, task: task, eventQuery: eventQuery, storeManager: storeManager)
	}

	override public init(viewSynchronizer: GeneralizedLogTaskViewSynchronizer, taskID: String, eventQuery: OCKEventQuery, storeManager: OCKSynchronizedStoreManager) {
		super.init(viewSynchronizer: viewSynchronizer, taskID: taskID, eventQuery: eventQuery, storeManager: storeManager)
	}

	public init(task: OCKAnyTask, eventQuery: OCKEventQuery, storeManager: OCKSynchronizedStoreManager) {
		let synchronizer = GeneralizedLogTaskViewSynchronizer()
		healthKitTask = task as? OCKHealthKitTask
		super.init(viewSynchronizer: synchronizer, task: task, eventQuery: eventQuery, storeManager: storeManager)
	}

	public init(taskID: String, eventQuery: OCKEventQuery, storeManager: OCKSynchronizedStoreManager) {
		let synchronizer = GeneralizedLogTaskViewSynchronizer()
		super.init(viewSynchronizer: synchronizer, taskID: taskID, eventQuery: eventQuery, storeManager: storeManager)
	}

	override open func didSelectTaskView(_ taskView: UIView & OCKTaskDisplayable, eventIndexPath: IndexPath) {
		logDelegate?.generalizedLogTaskViewController(self, didSelectAddOutcome: healthKitTask)
	}

	override open func taskView(_ taskView: UIView & OCKTaskDisplayable, didCreateOutcomeValueAt index: Int, eventIndexPath: IndexPath, sender: Any?) {
//		guard let generalizedLogTaskView = taskView as? GeneralizedLogTaskView else {
//			return
//		}
		//        let entryViews = generalizedLogTaskView.entryViews
		//        guard let units = entryViews.units, !units.isEmpty, let value = Double(units) else {
		//            return
		//        }
		//        let reason = insulinView.reason
		//        let entryDate = entryViews.entryDate
//
		//        let sample = HKDiscreteQuantitySample(insulinUnits: value, startDate: entryDate, reason: reason)
		//        HKHealthStore().save(sample) { _, error in
		//            if let error = error {
		//                ALog.error("Unable to save insulin values", error: error)
		//            }
		//        }
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
