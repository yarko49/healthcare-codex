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
		viewController.queryDate = eventQuery.dateInterval.start
		viewController.anyTask = task
		viewController.outcomeValue = value
		if let uuid = value?.healthKitUUID {
			viewController.outcome = try? careManager.dbFindFirstOutcome(sampleId: uuid)
		}
		viewController.modalPresentationStyle = .overFullScreen
		viewController.healthKitSampleHandler = { [weak viewController, weak self] newSample in
			guard let strongSelf = self else {
				return
			}
			strongSelf.healthKitStore.save(sample: newSample, completion: { result in
				switch result {
				case .success:
					if let outcomeValue = viewController?.outcomeValue {
						strongSelf.controller.deleteOutcome(value: outcomeValue) { result in
							switch result {
							case .success(let deletedSample):
								let lastOutcomeUplaodDate = UserDefaults.standard[healthKitOutcomesUploadDate: task.healthKitLinkage.quantityIdentifier.rawValue]
								if let carePlanId = task.carePlanId, newSample.startDate < lastOutcomeUplaodDate, let outcome = strongSelf.careManager.fetchOutcome(sample: newSample, deletedSample: deletedSample, task: task, carePlanId: carePlanId) {
									strongSelf.careManager.upload(outcomes: [outcome]) { result in
										if case .failure(let error) = result {
											ALog.error("unable to upload outcome", error: error)
										}
									}
								}
							case .failure(let error):
								ALog.error("Error deleteting data", error: error)
							}
						}
					} else {
						let lastOutcomeUplaodDate = UserDefaults.standard[healthKitOutcomesUploadDate: task.healthKitLinkage.quantityIdentifier.rawValue]
						if let carePlanId = task.carePlanId, newSample.startDate < lastOutcomeUplaodDate, let outcome = strongSelf.careManager.fetchOutcome(sample: newSample, deletedSample: nil, task: task, carePlanId: carePlanId) {
							strongSelf.careManager.upload(outcomes: [outcome]) { result in
								if case .failure(let error) = result {
									ALog.error("unable to upload outcome", error: error)
								}
							}
						}
					}
					DispatchQueue.main.async {
						viewController?.dismiss(animated: true, completion: nil)
					}
				case .failure(let error):
					ALog.error("Unable to save sample", error: error)
				}
			})
		}

		viewController.deleteAction = { [weak self, weak viewController] in
			guard let outcomeValue = viewController?.outcomeValue, let task = viewController?.healthKitTask else {
				viewController?.dismiss(animated: true, completion: nil)
				return
			}

			self?.deleteOutcome(value: outcomeValue, task: task, completion: { result in
				switch result {
				case .success(let sample):
					ALog.trace("\(sample.uuid) sample was deleted", metadata: nil)
				case .failure(let error):
					ALog.error("Error deleteting data", error: error)
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
}
