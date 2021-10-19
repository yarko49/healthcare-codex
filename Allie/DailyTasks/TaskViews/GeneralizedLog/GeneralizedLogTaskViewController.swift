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

typealias AllieHealthKitSampleHandler = (HKSample) -> Void

class GeneralizedLogTaskViewController: OCKTaskViewController<GeneralizedLogTaskController, GeneralizedLogTaskViewSynchronizer> {
	private var cancellables: Set<AnyCancellable> = []
	@Injected(\.careManager) var careManager: CareManager

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
		synchronizer.task = task
		super.init(viewSynchronizer: synchronizer, task: task, eventQuery: eventQuery, storeManager: storeManager)
	}

	public init(taskID: String, eventQuery: OCKEventQuery, storeManager: OCKSynchronizedStoreManager) {
		let synchronizer = GeneralizedLogTaskViewSynchronizer()
		super.init(viewSynchronizer: synchronizer, taskID: taskID, eventQuery: eventQuery, storeManager: storeManager)
	}

	override open func didSelectTaskView(_ taskView: UIView & OCKTaskDisplayable, eventIndexPath: IndexPath) {
		didSelectOutcome(value: nil, eventIndexPath: eventIndexPath, sender: nil)
	}

	override open func taskView(_ taskView: UIView & OCKTaskDisplayable, didCreateOutcomeValueAt index: Int, eventIndexPath: IndexPath, sender: Any?) {
		super.taskView(taskView, didCreateOutcomeValueAt: index, eventIndexPath: eventIndexPath, sender: sender)
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

	override func taskView(_ taskView: UIView & OCKTaskDisplayable, didSelectOutcomeValueAt index: Int, eventIndexPath: IndexPath, sender: Any?) {
		do {
			_ = try controller.validatedViewModel()
			let event = try controller.validatedEvent(forIndexPath: eventIndexPath)
			guard let outcome = event.outcome, index < outcome.values.count else {
				throw AllieError.missing("No Outcome Value for Event at index \(index)")
			}

			let value = outcome.values[index]
			didSelectOutcome(value: value, eventIndexPath: eventIndexPath, sender: sender)
		} catch {
			if delegate == nil {
				ALog.error("A task error occurred, but no delegate was set to forward it to!", error: error)
			}
			delegate?.taskViewController(self, didEncounterError: error)
		}
	}

	func didSelectOutcome(value: OCKOutcomeValue?, eventIndexPath: IndexPath, sender: Any?) {
		guard let event = controller.eventFor(indexPath: eventIndexPath), let task = event.task as? OCKHealthKitTask else {
			return
		}
		let viewController = GeneralizedLogTaskDetailViewController()
		viewController.task = task
		viewController.outcomeValue = value
		viewController.modalPresentationStyle = .overFullScreen
		viewController.healthKitSampleHandler = { [weak viewController] sample in
			HKHealthStore().save(sample) { [weak self] _, error in
				if let error = error {
					ALog.error("Unable to save sample", error: error)
				} else {
					if let outcomeValue = viewController?.outcomeValue {
						self?.deleteOutcome(value: outcomeValue, task: task, completion: { result in
							switch result {
							case .success(let sample):
								ALog.info("\(sample.uuid) sample was deleted", metadata: nil)
							case .failure(let error):
								ALog.error("Error deleteting data \(error.localizedDescription)", metadata: nil)
							}
						})
					}
					let lastOutcomeUplaodDate = UserDefaults.standard[lastOutcomesUploadDate: task.healthKitLinkage.quantityIdentifier.rawValue]
					if let carePlanId = task.carePlanId, sample.startDate < lastOutcomeUplaodDate, let outcome = CHOutcome(sample: sample, task: task, carePlanId: carePlanId) {
						self?.careManager.upload(outcomes: [outcome])
					}
					DispatchQueue.main.async {
						viewController?.dismiss(animated: true, completion: nil)
					}
				}
			}
		}

		viewController.deleteAction = { [weak self, weak viewController] in
			guard let outcomeValue = viewController?.outcomeValue, let task = viewController?.task else {
				viewController?.dismiss(animated: true, completion: nil)
				return
			}

			self?.deleteOutcome(value: outcomeValue, task: task, completion: { result in
				switch result {
				case .success(let sample):
					ALog.info("\(sample.uuid) sample was deleted", metadata: nil)
				case .failure(let error):
					ALog.error("Error deleteting data \(error.localizedDescription)", metadata: nil)
				}
				DispatchQueue.main.async {
					viewController?.dismiss(animated: true, completion: nil)
				}
			})
		}

		viewController.cancelAction = { [weak viewController] in
			viewController?.dismiss(animated: true, completion: nil)
		}

		tabBarController?.showDetailViewController(viewController, sender: self)
	}

	func deleteOutcome(value: OCKOutcomeValue, task: OCKHealthKitTask, completion: @escaping AllieResultCompletion<HKSample>) {
		controller.deleteOutcome(value: value) { [weak self] result in
			switch result {
			case .success(let sample):
				ALog.info("Did delete sample \(sample.uuid)", metadata: nil)
				if let carePlanId = task.carePlanId, var chOutcome = CHOutcome(sample: sample, task: task, carePlanId: carePlanId) {
					chOutcome.deletedDate = Date()
					self?.careManager.upload(outcomes: [chOutcome])
				}
				completion(.success(sample))
			case .failure(let error):
				ALog.error("Error deleteting data \(error.localizedDescription)", metadata: nil)
				completion(.failure(error))
			}
		}
	}
}
