//
//  CareManager+Outcomes.swift
//  Allie
//
//  Created by Waqar Malik on 9/11/21.
//

import CareKit
import CareKitStore
import Combine
import Foundation
import HealthKit

extension CareManager {
	func syncCreateOrUpdate(outcome: CHOutcome, queue: DispatchQueue) -> OCKOutcome {
		var ockOutcome = OCKOutcome(outcome: outcome)
		var query = OCKOutcomeQuery()
		if let remoteId = outcome.remoteID {
			query.remoteIDs = [remoteId]
		}

		let dispatchGroup = DispatchGroup()
		dispatchGroup.enter()
		store.fetchOutcome(query: query, callbackQueue: queue) { [weak self] result in
			switch result {
			case .failure(let error):
				ALog.error("\(error.localizedDescription)")
				self?.store.addOutcome(ockOutcome, callbackQueue: queue, completion: { addResult in
					switch addResult {
					case .failure(let error):
						ALog.error("\(error.localizedDescription)")
					case .success(let newOutcome):
						ockOutcome = newOutcome
					}
					dispatchGroup.leave()
				})
			case .success(let existingOutcome):
				let merged = existingOutcome.merged(newOutcome: ockOutcome)
				self?.store.updateOutcome(merged, callbackQueue: queue, completion: { updateResult in
					switch updateResult {
					case .failure(let error):
						ALog.error("\(error.localizedDescription)")
					case .success(let newOutcome):
						ockOutcome = newOutcome
					}
					dispatchGroup.leave()
				})
			}
		}

		dispatchGroup.wait()
		return ockOutcome
	}

	func syncCreateOrUpdate(outcomes: [CHOutcome], queue: DispatchQueue) -> [OCKOutcome] {
		let mapped = outcomes.map { outcome -> OCKOutcome in
			OCKOutcome(outcome: outcome)
		}

		var storeOutcomes: [OCKOutcome] = []
		let dispatchGroup = DispatchGroup()
		for outcome in mapped {
			dispatchGroup.enter()
			store.process(outcome: outcome, callbackQueue: queue) { result in
				switch result {
				case .failure(let error):
					ALog.error("\(error.localizedDescription)")
				case .success(let newOutcome):
					storeOutcomes.append(newOutcome)
				}
				dispatchGroup.leave()
			}
		}
		dispatchGroup.wait()
		return storeOutcomes
	}

	func processOutcome(notification: OCKOutcomeNotification) {
		guard let outcome = notification.outcome as? OCKOutcome else {
			return
		}

		var taskQuery = OCKTaskQuery()
		taskQuery.uuids.append(outcome.taskUUID)
		store.fetchTasks(query: taskQuery, callbackQueue: .main) { [weak self] taskResult in
			switch taskResult {
			case .failure(let error):
				ALog.error("\(error.localizedDescription)")
			case .success(let tasks):
				guard let task = tasks.first, let carePlanId = task.userInfo?["carePlanId"] else {
					return
				}

				self?.upload(outcome: outcome, task: task, carePlanId: carePlanId)
			}
		}
		ALog.info("\(notification.outcome)")
	}

	func upload(outcomes: [OCKAnyOutcome]) {
		guard !outcomes.isEmpty else {
			return
		}
		let group = DispatchGroup()
		var chOutcomes: [CHOutcome] = []
		for outcome in outcomes {
			let hkOutcome = outcome as? OCKHealthKitOutcome
			let ockOutcome = outcome as? OCKOutcome
			guard let taskUUID = hkOutcome?.taskUUID ?? ockOutcome?.taskUUID else {
				continue
			}
			group.enter()
			var taskQuery = OCKTaskQuery()
			taskQuery.uuids.append(taskUUID)
			store.fetchTasks(query: taskQuery, callbackQueue: .main) { taskResult in
				switch taskResult {
				case .failure(let error):
					ALog.error("\(error.localizedDescription)")
				case .success(let tasks):
					guard let task = tasks.first, let carePlanId = task.userInfo?["carePlanId"] else {
						return
					}
					if let theOutcome = hkOutcome {
						let chOutcome = CHOutcome(hkOutcome: theOutcome, carePlanID: carePlanId, taskID: task.id)
						chOutcomes.append(chOutcome)
					} else if let theOutcome = ockOutcome {
						let chOutcome = CHOutcome(outcome: theOutcome, carePlanID: carePlanId, taskID: task.id)
						chOutcomes.append(chOutcome)
					}
				}
				group.leave()
			}

			group.notify(queue: .main) { [weak self] in
				self?.upload(outcomes: outcomes)
			}
		}
	}

	func upload(outcomes: [CHOutcome]) {
		guard !outcomes.isEmpty else {
			return
		}

		networkAPI.post(outcomes: outcomes)
			.sink { completion in
				switch completion {
				case .failure(let error):
					ALog.error("\(error.localizedDescription)")
				case .finished:
					ALog.info("Uploaded the outcome")
				}
			} receiveValue: { response in
				ALog.info("\(response.outcomes)")
			}.store(in: &cancellables)
	}

	func upload(samples: [HKSample], quantityIdentifier: HKQuantityTypeIdentifier) -> AnyPublisher<[CHOutcome], Error> {
		guard !samples.isEmpty else {
			return Fail(error: AllieError.missing("No samples to send"))
				.eraseToAnyPublisher()
		}
		return healthKitStore.fetchTasks(quantityIdentifier: quantityIdentifier)
			.tryMap { tasks -> OCKHealthKitTask in
				var unique: [String: OCKHealthKitTask] = [:]
				tasks.forEach { task in
					unique[task.id] = task
				}

				let filteredTasks: [OCKHealthKitTask] = unique.reduce([]) { partialResult, item in
					var result = partialResult
					result.append(item.value)
					return result
				}
				guard let first = filteredTasks.first, filteredTasks.count == 1 else {
					throw AllieError.invalid("More than one task with same HKQuantityTypeIdentifier = \(unique.keys)")
				}
				return first
			}.tryMap { task -> [CHOutcome] in
				guard let carePlanId = task.carePlanId else {
					throw AllieError.missing("Care Plan Id Missing")
				}
				let outcomes = samples.compactMap { sample in
					CHOutcome(sample: sample, task: task, carePlanId: carePlanId)
				}

				return outcomes
			}.flatMap { outcomes in
				self.networkAPI.post(outcomes: outcomes)
					.tryMap { response in
						response.outcomes
					}.eraseToAnyPublisher()
			}.eraseToAnyPublisher()
	}

	func upload(outcome: OCKOutcome, task: OCKTask, carePlanId: String) {
		let allieOutcome = CHOutcome(outcome: outcome, carePlanID: carePlanId, taskID: task.id)
		networkAPI.post(outcomes: [allieOutcome])
			.sink { completion in
				switch completion {
				case .failure(let error):
					ALog.error("\(error.localizedDescription)")
				case .finished:
					ALog.info("Uploaded the outcome")
				}
			} receiveValue: { response in
				ALog.info("\(response.outcomes)")
			}.store(in: &cancellables)
	}

	func save(outcomes: [CHOutcome]) -> Future<[OCKOutcome], Error> {
		Future { [weak self] promise in
			self?.save(outcomes: outcomes) { result in
				switch result {
				case .success(let outcomes):
					promise(.success(outcomes))
				case .failure(let error):
					promise(.failure(error))
				}
			}
		}
	}

	func save(outcomes: [CHOutcome], completion: @escaping AllieResultCompletion<[OCKOutcome]>) {
		let ockOutomes = outcomes.compactMap { outcome -> OCKOutcome? in
			OCKOutcome(outcome: outcome)
		}
		store.addOutcomes(ockOutomes, callbackQueue: .main) { result in
			switch result {
			case .success(let outcomes):
				completion(.success(outcomes))
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}

	func deleteOutcomes(task: CHTask, completion: @escaping AllieResultCompletion<[OCKOutcome]>) {
		let dateInterval = DateInterval(start: task.effectiveDate, end: Date.distantFuture)
		var outcomeQuery = OCKOutcomeQuery(dateInterval: dateInterval)
		outcomeQuery.taskIDs = [task.id]
		store.fetchOutcomes(query: outcomeQuery) { [weak self] fetchResult in
			switch fetchResult {
			case .failure(let error):
				ALog.error("No outcoms found for task id \(task.id)", error: error)
				completion(.failure(error))
			case .success(let outcomes):
				self?.store.deleteOutcomes(outcomes) { deleteResult in
					switch deleteResult {
					case .failure(let error):
						ALog.error("Unable to delete outcomes for task \(task.id)", error: error)
						completion(.failure(error))
					case .success(let deletedOutcomes):
						completion(.success(deletedOutcomes))
					}
				}
			}
		}
	}

	func synchronizeOutcomes(carePlanId: String, taskId: String, completion: @escaping AllieResultCompletion<Bool>) {
		networkAPI.getOutcomes(carePlanId: carePlanId, taskId: taskId)
			.sink { completionResult in
				if case .failure(let error) = completionResult {
					completion(.failure(error))
				}
			} receiveValue: { [weak self] outcomeResponse in
				guard let strongSelf = self, !outcomeResponse.outcomes.isEmpty else {
					completion(.success(true))
					return
				}
				strongSelf.save(outcomes: outcomeResponse.outcomes) { saveResult in
					switch saveResult {
					case .failure(let error):
						completion(.failure(error))
					case .success:
						strongSelf.synchronizeOutcomes(metaData: outcomeResponse.metaData, completion: completion)
					}
				}
			}.store(in: &cancellables)
	}

	func synchronizeOutcomes(metaData: CHOutcomeResponse.MetaData, completion: @escaping AllieResultCompletion<Bool>) {
		guard let next = metaData.next else {
			completion(.success(true))
			return
		}
		networkAPI.getOutcomes(url: next)
			.sink { completionResult in
				if case .failure(let error) = completionResult {
					completion(.failure(error))
				}
			} receiveValue: { [weak self] outcomeResponse in
				guard let strongSelf = self, !outcomeResponse.outcomes.isEmpty else {
					completion(.success(true))
					return
				}
				strongSelf.save(outcomes: outcomeResponse.outcomes) { saveResult in
					switch saveResult {
					case .failure(let error):
						completion(.failure(error))
					case .success:
						strongSelf.synchronizeOutcomes(metaData: outcomeResponse.metaData, completion: completion)
					}
				}
			}.store(in: &cancellables)
	}
}
