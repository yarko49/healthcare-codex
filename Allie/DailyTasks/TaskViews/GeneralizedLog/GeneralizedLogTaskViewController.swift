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

class GeneralizedLogTaskViewController: OCKTaskViewController<GeneralizedLogTaskController, GeneralizedLogTaskViewSynchronizer> {
	private var cancellables: Set<AnyCancellable> = []
	var healthKitTask: OCKHealthKitTask?

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
		guard let healthKitTask = healthKitTask else {
			return
		}

		let viewController = GeneralizedLogTaskDetailViewController()
		viewController.task = healthKitTask
		viewController.modalPresentationStyle = .overFullScreen
		viewController.saveAction = { [weak viewController] in
			viewController?.dismiss(animated: true, completion: nil)
		}

		viewController.cancelAction = { [weak viewController] in
			viewController?.dismiss(animated: true, completion: nil)
		}

		tabBarController?.showDetailViewController(viewController, sender: self)
	}

	override open func taskView(_ taskView: UIView & OCKTaskDisplayable, didCreateOutcomeValueAt index: Int, eventIndexPath: IndexPath, sender: Any?) {}

	private func notifyDelegateAndResetViewOnError<Success, Error>(result: Result<Success, Error>) {
		if case .failure(let error) = result {
			if delegate == nil {
				ALog.error("A task error occurred, but no delegate was set to forward it to!", error: error)
			}
			delegate?.taskViewController(self, didEncounterError: error)
			controller.taskEvents = controller.taskEvents // triggers an update to the view
		}
	}

//	override func taskView(_ taskView: UIView & OCKTaskDisplayable, didSelectOutcomeValueAt index: Int, eventIndexPath: IndexPath, sender: Any?) {
//		do {
//			_ = try controller.validatedViewModel()
//			let event = try controller.validatedEvent(forIndexPath: eventIndexPath)
//			guard let outcome = event.outcome, index < outcome.values.count else {
//				throw AllieError.missing("No Outcome Value for Event at index \(index)")
//			}
//
//			if let hkOutcome = outcome as? OCKHealthKitOutcome, hkOutcome.isOwnedByApp == false {
//				throw AllieError.forbidden("Cannot delete this outcome")
//			}
//
//			guard let healthKitTask = healthKitTask else {
//				throw AllieError.missing("HealthKit task is missing")
//			}
//
//			let viewController = GeneralizedLogTaskDetailViewController()
//			viewController.task = healthKitTask
//			viewController.modalPresentationStyle = .overFullScreen
//			viewController.saveAction = { [weak viewController] in
//				viewController?.dismiss(animated: true, completion: nil)
//			}
//
//			viewController.cancelAction = { [weak viewController] in
//				viewController?.dismiss(animated: true, completion: nil)
//			}
//
//			viewController.deleteAction = { [weak viewController] in
//				viewController?.dismiss(animated: true, completion: {
//					super.taskView(taskView, didSelectOutcomeValueAt: index, eventIndexPath: eventIndexPath, sender: sender)
//				})
//			}
//
//			viewController.outcome = outcome
//			tabBarController?.showDetailViewController(viewController, sender: self)
//		} catch {
//			if delegate == nil {
//				ALog.error("A task error occurred, but no delegate was set to forward it to!", error: error)
//			}
//			delegate?.taskViewController(self, didEncounterError: error)
//		}
//	}
}
