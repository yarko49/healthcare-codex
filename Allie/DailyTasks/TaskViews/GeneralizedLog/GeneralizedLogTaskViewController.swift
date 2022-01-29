//
//  GeneralizedLogTaskViewController.swift
//  Allie
//
//  Created by Waqar Malik on 7/10/21.
//

import CareKit
import CareKitStore
import CareKitUI
import CodexFoundation
import Combine
import HealthKit
import UIKit

typealias AllieHealthKitSampleHandler = (HKSample) -> Void
typealias AllieOutcomeValueHandler = (OCKOutcomeValue) -> Void

class GeneralizedLogTaskViewController: OCKTaskViewController<GeneralizedLogTaskController, GeneralizedLogTaskViewSynchronizer> {
	private var cancellables: Set<AnyCancellable> = []
	@Injected(\.careManager) var careManager: CareManager
	@Injected(\.healthKitManager) var healthKitStore: HealthKitManager
	var eventQuery = OCKEventQuery(for: Date())

	override public init(controller: GeneralizedLogTaskController, viewSynchronizer: GeneralizedLogTaskViewSynchronizer) {
		super.init(controller: controller, viewSynchronizer: viewSynchronizer)
	}

	override public init(viewSynchronizer: GeneralizedLogTaskViewSynchronizer, task: OCKAnyTask, eventQuery: OCKEventQuery, storeManager: OCKSynchronizedStoreManager) {
		self.eventQuery = eventQuery
		super.init(viewSynchronizer: viewSynchronizer, task: task, eventQuery: eventQuery, storeManager: storeManager)
	}

	override public init(viewSynchronizer: GeneralizedLogTaskViewSynchronizer, taskID: String, eventQuery: OCKEventQuery, storeManager: OCKSynchronizedStoreManager) {
		self.eventQuery = eventQuery
		super.init(viewSynchronizer: viewSynchronizer, taskID: taskID, eventQuery: eventQuery, storeManager: storeManager)
	}

	public init(task: OCKAnyTask, eventQuery: OCKEventQuery, storeManager: OCKSynchronizedStoreManager) {
		let synchronizer = GeneralizedLogTaskViewSynchronizer()
		synchronizer.task = task
		self.eventQuery = eventQuery
		super.init(viewSynchronizer: synchronizer, task: task, eventQuery: eventQuery, storeManager: storeManager)
	}

	public init(taskID: String, eventQuery: OCKEventQuery, storeManager: OCKSynchronizedStoreManager) {
		let synchronizer = GeneralizedLogTaskViewSynchronizer()
		self.eventQuery = eventQuery
		super.init(viewSynchronizer: synchronizer, taskID: taskID, eventQuery: eventQuery, storeManager: storeManager)
	}

	override open func didSelectTaskView(_ taskView: UIView & OCKTaskDisplayable, eventIndexPath: IndexPath) {
		didSelectOutcome(values: [], eventIndexPath: eventIndexPath, sender: nil)
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

			guard let outcome = event.outcome else {
				throw AllieError.missing("No Outcome")
			}

			guard index < outcome.recordsCount else {
				throw AllieError.missing("No Outcome Value for Event at index \(index)")
			}

			let values = outcome.getValuesForRecord(at: index)
			didSelectOutcome(values: values, eventIndexPath: eventIndexPath, sender: sender)
		} catch {
			if delegate == nil {
				ALog.error("A task error occurred, but no delegate was set to forward it to!", error: error)
			}
			delegate?.taskViewController(self, didEncounterError: error)
		}
	}

	func didSelectOutcome(values: [OCKOutcomeValue], eventIndexPath: IndexPath, sender: Any?) {
		guard let event = controller.eventFor(indexPath: eventIndexPath), let task = event.task as? OCKHealthKitTask else {
			return
		}
		let value = values.first
		let taskDetailViewController = GeneralizedLogTaskDetailViewController()
		taskDetailViewController.queryDate = eventQuery.dateInterval.start
		taskDetailViewController.anyTask = task
		taskDetailViewController.outcomeValues = values
		if let uuid = value?.healthKitUUID {
			taskDetailViewController.outcome = try? careManager.dbFindFirstOutcome(sampleId: uuid)
		}
		taskDetailViewController.modalPresentationStyle = .overFullScreen

		taskDetailViewController.healthKitSampleHandler = { [weak taskDetailViewController, weak self] newSample in
			guard let strongSelf = self, let viewController = taskDetailViewController else {
				return
			}
			Task {
				do {
					_ = try await strongSelf.healthKitStore.save(sample: newSample)
					var deletedSample: HKSample?
					if let outcomeValue = viewController.outcomeValues.first {
						deletedSample = try await strongSelf.controller.deleteOutcome(value: outcomeValue)
					}
					let lastOutcomeUplaodDate = UserDefaults.standard[healthKitOutcomesUploadDate: task.healthKitLinkage.quantityIdentifier.rawValue]
					if let carePlanId = task.carePlanId, newSample.startDate < lastOutcomeUplaodDate, let outcome = strongSelf.careManager.fetchOutcome(sample: newSample, deletedSample: deletedSample, task: task, carePlanId: carePlanId) {
						_ = try await strongSelf.careManager.upload(outcomes: [outcome])
					}
				} catch {
					ALog.error("Unable to save sample", error: error)
				}

				DispatchQueue.main.async {
					viewController.dismiss(animated: true, completion: nil)
				}
			}
		}

		taskDetailViewController.deleteAction = { [weak self, weak taskDetailViewController] in
			guard let strongSelf = self, let viewController = taskDetailViewController else {
				return
			}
			guard let outcomeValue = viewController.outcomeValues.first, let task = viewController.healthKitTask else {
				viewController.dismiss(animated: true, completion: nil)
				return
			}

			strongSelf.deleteOutcome(value: outcomeValue, task: task, completion: { result in
				switch result {
				case .success(let sample):
					ALog.trace("\(sample.uuid) sample was deleted", metadata: nil)
				case .failure(let error):
					ALog.error("Error deleteting data", error: error)
				}
				DispatchQueue.main.async {
					viewController.dismiss(animated: true, completion: nil)
				}
			})
		}

		taskDetailViewController.cancelAction = { [weak taskDetailViewController] in
			guard let viewController = taskDetailViewController else {
				return
			}

			viewController.dismiss(animated: true, completion: nil)
		}

		tabBarController?.showDetailViewController(taskDetailViewController, sender: self)
	}

	func deleteOutcome(value: OCKOutcomeValue, task: OCKHealthKitTask, completion: @escaping AllieResultCompletion<CHOutcome>) {
		controller.deleteOutcome(value: value) { [weak self] result in
			switch result {
			case .success(let sample):
				ALog.trace("Did delete sample \(sample.uuid)", metadata: nil)
				do {
					var outcome: CHOutcome?
					if let carePlanId = task.carePlanId {
						outcome = self?.careManager.fetchOutcome(sample: sample, deletedSample: sample, task: task, carePlanId: carePlanId)
					} else {
						outcome = try self?.careManager.dbFindFirstOutcome(sample: sample)
					}
					guard var existingOutcome = outcome else {
						throw AllieError.missing("\(sample.uuid.uuidString)")
					}
					existingOutcome.deletedDate = Date()
					self?.careManager.upload(outcomes: [existingOutcome]) { result in
						if case .failure(let error) = result {
							ALog.error("unable to upload outcome", error: error)
						}
						completion(.success(existingOutcome))
					}
				} catch {
					completion(.failure(error))
				}
			case .failure(let error):
				ALog.error("Error deleteting data", error: error)
				completion(.failure(error))
			}
		}
	}

	func deleteOutcome(value: OCKOutcomeValue, task: OCKHealthKitTask) async throws -> CHOutcome {
		let sample = try await controller.deleteOutcome(value: value)
		ALog.trace("Did delete sample \(sample.uuid)", metadata: nil)
		var outcome: CHOutcome?
		if let carePlanId = task.carePlanId {
			outcome = careManager.fetchOutcome(sample: sample, deletedSample: sample, task: task, carePlanId: carePlanId)
		} else {
			outcome = try careManager.dbFindFirstOutcome(sample: sample)
		}
		guard var existingOutcome = outcome else {
			throw AllieError.missing("\(sample.uuid.uuidString)")
		}
		existingOutcome.deletedDate = Date()
		_ = try await careManager.upload(outcomes: [existingOutcome])
		return existingOutcome
	}
}
