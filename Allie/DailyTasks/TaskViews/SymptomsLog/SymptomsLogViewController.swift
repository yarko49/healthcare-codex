//
//  SymptomsViewController.swift
//  Allie
//
//  Created by Waqar Malik on 10/26/21.
//

import CareKit
import CareKitStore
import CareKitUI
import Combine
import HealthKit
import UIKit

class SymptomsLogViewController: OCKTaskViewController<SymptomsLogTaskController, SymptomsLogViewSynchronizer> {
	private var cancellables: Set<AnyCancellable> = []
	@Injected(\.careManager) var careManager: CareManager
	var eventQuery = OCKEventQuery(for: Date())

	override public init(controller: SymptomsLogTaskController, viewSynchronizer: SymptomsLogViewSynchronizer) {
		super.init(controller: controller, viewSynchronizer: viewSynchronizer)
	}

	override public init(viewSynchronizer: SymptomsLogViewSynchronizer, task: OCKAnyTask, eventQuery: OCKEventQuery, storeManager: OCKSynchronizedStoreManager) {
		self.eventQuery = eventQuery
		super.init(viewSynchronizer: viewSynchronizer, task: task, eventQuery: eventQuery, storeManager: storeManager)
	}

	override public init(viewSynchronizer: SymptomsLogViewSynchronizer, taskID: String, eventQuery: OCKEventQuery, storeManager: OCKSynchronizedStoreManager) {
		self.eventQuery = eventQuery
		super.init(viewSynchronizer: viewSynchronizer, taskID: taskID, eventQuery: eventQuery, storeManager: storeManager)
	}

	public init(task: OCKAnyTask, eventQuery: OCKEventQuery, storeManager: OCKSynchronizedStoreManager) {
		let synchronizer = SymptomsLogViewSynchronizer()
		synchronizer.task = task
		self.eventQuery = eventQuery
		super.init(viewSynchronizer: synchronizer, task: task, eventQuery: eventQuery, storeManager: storeManager)
	}

	public init(taskID: String, eventQuery: OCKEventQuery, storeManager: OCKSynchronizedStoreManager) {
		let synchronizer = SymptomsLogViewSynchronizer()
		self.eventQuery = eventQuery
		super.init(viewSynchronizer: synchronizer, taskID: taskID, eventQuery: eventQuery, storeManager: storeManager)
	}

	override open func didSelectTaskView(_ taskView: UIView & OCKTaskDisplayable, eventIndexPath: IndexPath) {
		didSelectOutcome(value: nil, index: nil, eventIndexPath: eventIndexPath, outcome: nil, sender: nil)
	}

	override open func taskView(_ taskView: UIView & OCKTaskDisplayable, didCreateOutcomeValueAt index: Int, eventIndexPath: IndexPath, sender: Any?) {
		super.taskView(taskView, didCreateOutcomeValueAt: index, eventIndexPath: eventIndexPath, sender: sender)
	}

	override func taskView(_ taskView: UIView & OCKTaskDisplayable, didSelectOutcomeValueAt index: Int, eventIndexPath: IndexPath, sender: Any?) {
		do {
			_ = try controller.validatedViewModel()
			let event = try controller.validatedEvent(forIndexPath: eventIndexPath)
			guard let outcome = event.outcome, index < outcome.values.count else {
				throw AllieError.missing("No Outcome Value for Event at index \(index)")
			}

			let value = outcome.values[index]
			didSelectOutcome(value: value, index: index, eventIndexPath: eventIndexPath, outcome: outcome, sender: sender)
		} catch {
			if delegate == nil {
				ALog.error("A task error occurred, but no delegate was set to forward it to!", error: error)
			}
			delegate?.taskViewController(self, didEncounterError: error)
		}
	}

	func didSelectOutcome(value: OCKOutcomeValue?, index: Int?, eventIndexPath: IndexPath, outcome: OCKAnyOutcome?, sender: Any?) {
		guard let event = controller.eventFor(indexPath: eventIndexPath), let task = event.task as? OCKTask else {
			return
		}
		let viewController = GeneralizedLogTaskDetailViewController()
		viewController.queryDate = eventQuery.dateInterval.start
		viewController.anyTask = task
		viewController.outcomeValue = value
		viewController.outcomeIndex = index
		viewController.modalPresentationStyle = .overFullScreen

		viewController.deleteAction = { [weak self, weak viewController] in
			guard let strongSelf = self, let index = viewController?.outcomeIndex else {
				viewController?.dismiss(animated: true, completion: nil)
				return
			}

			do {
				let event = try strongSelf.controller.validatedEvent(forIndexPath: eventIndexPath)
				guard let eventOutcome = event.outcome as? OCKOutcome, index < eventOutcome.values.count else {
					throw AllieError.missing("No Outcome Value for Event at index \(index)")
				}
				strongSelf.deleteOutcomeValue(at: index, for: eventOutcome, task: task) { deletedResult in
					switch deletedResult {
					case .failure(let error):
						ALog.error("unable to upload outcome", error: error)
					case .success(let deletedOutcome):
						ALog.trace("Uploaded the outcome \(deletedOutcome.remoteId ?? "")")
					}
					DispatchQueue.main.async {
						viewController?.dismiss(animated: true, completion: nil)
					}
				}
			} catch {
				ALog.error("Cannot delete outcome", error: error)
				DispatchQueue.main.async {
					viewController?.dismiss(animated: true, completion: nil)
				}
			}
		}

		viewController.outcomeValueHandler = { [weak viewController, weak self] newOutcomeValue in
			guard let strongSelf = self, let carePlanId = task.carePlanId else {
				return
			}
			if let index = index, let ockOutcome = outcome as? OCKOutcome, viewController?.outcomeValue != nil {
				strongSelf.update(value: newOutcomeValue, for: ockOutcome, at: index, eventIndexPath: eventIndexPath, task: task) { updateResult in
					switch updateResult {
					case .failure(let error):
						ALog.error("Error updating outcome", error: error)
					case .success(let outcome):
						ALog.info("Did update value \(outcome.uuid)")
					}
					DispatchQueue.main.async {
						viewController?.dismiss(animated: true, completion: nil)
					}
				}
			} else {
				strongSelf.appendOutcome(value: newOutcomeValue, carePlanId: carePlanId, task: task, eventIndexPath: eventIndexPath) { appendResult in
					switch appendResult {
					case .failure(let error):
						ALog.error("Error appending outcome", error: error)
					case .success(let outcome):
						ALog.info("Did append value \(outcome.uuid)")
					}
					DispatchQueue.main.async {
						viewController?.dismiss(animated: true, completion: nil)
					}
				}
			}
		}

		viewController.cancelAction = { [weak viewController] in
			viewController?.dismiss(animated: true, completion: nil)
		}

		tabBarController?.showDetailViewController(viewController, sender: self)
	}

	func appendOutcome(value newOutcomeValue: OCKOutcomeValue, carePlanId: String, task: OCKTask, eventIndexPath indexPath: IndexPath, completion: AllieResultCompletion<CHOutcome>?) {
		controller.append(value: newOutcomeValue, at: indexPath) { [weak self] result in
			guard let strongSelf = self else {
				completion?(.failure(AllieError.forbidden("Self is deallocated")))
				return
			}
			switch result {
			case .failure(let error):
				ALog.error("Error adding outcome", error: error)
				completion?(.failure(error))
			case .success(let outcome):
				guard var ockOutcome = outcome as? OCKOutcome else {
					completion?(.failure(AllieError.invalid("Added outcome is wrong type")))
					return
				}
				ockOutcome.values = [newOutcomeValue]
				var chOutcome = CHOutcome(outcome: ockOutcome, carePlanID: carePlanId, task: task)
				chOutcome.remoteId = nil
				chOutcome.createdDate = newOutcomeValue.createdDate
				chOutcome.effectiveDate = newOutcomeValue.createdDate
				strongSelf.careManager.upload(outcomes: [chOutcome]) { uploadResult in
					switch uploadResult {
					case .failure(let error):
						completion?(.failure(error))
					case .success(let uploaded):
						completion?(.success(uploaded[0]))
					}
				}
			}
		}
	}

	func deleteOutcomeValue(at index: Int, for outcome: OCKOutcome, task: OCKTask, completion: AllieResultCompletion<CHOutcome>?) {
		controller.deleteOutcomeValue(at: index, for: outcome) { [weak self] deleteResult in
			guard let strongSelf = self else {
				completion?(.failure(AllieError.missing("Self is deallocated")))
				return
			}
			switch deleteResult {
			case .success(let deletedOutcome):
				guard let deleted = deletedOutcome as? OCKOutcome, let carePlanId = task.carePlanId else {
					completion?(.failure(AllieError.invalid("Outcome type is wrong")))
					return
				}
				var chOutcome = CHOutcome(outcome: deleted, carePlanID: carePlanId, task: task)
				chOutcome.deletedDate = Date()
				if let existing = try? strongSelf.careManager.dbFindFirstOutcome(uuid: outcome.uuid) {
					chOutcome.remoteId = existing.remoteId
					chOutcome.createdDate = existing.createdDate
					chOutcome.effectiveDate = existing.effectiveDate
				}

				strongSelf.careManager.upload(outcomes: [chOutcome]) { uploadResult in
					switch uploadResult {
					case .failure(let error):
						ALog.error("unable to upload outcome", error: error)
						completion?(.failure(error))
					case .success(let uploadedResponse):
						completion?(.success(uploadedResponse[0]))
					}
				}
			case .failure(let error):
				completion?(.failure(error))
			}
		}
	}

	// swiftlint:disable:next function_parameter_count
	func update(value: OCKOutcomeValue, for outcome: OCKOutcome, at index: Int, eventIndexPath: IndexPath, task: OCKTask, completion: AllieResultCompletion<CHOutcome>?) {
		controller.update(value: value, at: eventIndexPath, index: index) { [weak self] result in
			guard let strongSelf = self else {
				completion?(.failure(AllieError.missing("Self is deallocated")))
				return
			}
			switch result {
			case .failure(let error):
				ALog.error("Unable to update outcome value", error: error)
				completion?(.failure(error))
			case .success(let updatdOutcome):
				guard var updated = updatdOutcome as? OCKOutcome, let carePlanId = task.carePlanId else {
					ALog.error("Outcome type is wrong")
					completion?(.failure(AllieError.forbidden("Unable to update outcome \(outcome.uuid)")))
					return
				}
				updated.values = [value]
				var chOutcome = CHOutcome(outcome: updated, carePlanID: carePlanId, task: task)
				chOutcome.updatedDate = Date()
				chOutcome.createdDate = value.createdDate
				chOutcome.effectiveDate = value.createdDate
				if let existing = try? strongSelf.careManager.dbFindFirstOutcome(uuid: outcome.uuid) {
					chOutcome.remoteId = existing.remoteId
				}
				strongSelf.careManager.upload(outcomes: [chOutcome]) { uploadResult in
					switch uploadResult {
					case .failure(let error):
						completion?(.failure(error))
					case .success(let uploaded):
						completion?(.success(uploaded[0]))
					}
				}
			}
		}
	}
}
