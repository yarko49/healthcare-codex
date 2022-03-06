//
//  CareManager+Outcomes.swift
//  Allie
//
//  Created by Waqar Malik on 9/11/21.
//

import CareKit
import CareKitStore
import CareModel
import Combine
import CoreData
import Foundation
import HealthKit

extension CareManager {
	func processOutcome(notification: OCKOutcomeNotification) {
		guard let outcome = notification.outcome as? OCKOutcome else {
			return
		}

		Task.detached(priority: .userInitiated) { [weak self] in
			guard let strongSelf = self else {
				return
			}
			do {
				var taskQuery = OCKTaskQuery()
				taskQuery.uuids.append(outcome.taskUUID)
				let tasks = try await strongSelf.store.fetchTasks(query: taskQuery)
				guard let task = tasks.first, let carePlanId = task.userInfo?["carePlanId"] else {
					throw AllieError.missing("Required data for task")
				}

				_ = try await strongSelf.upload(outcome: outcome, task: task, carePlanId: carePlanId)
				ALog.info("\(notification.outcome)")
			} catch {
				ALog.error("process outcome notification", error: error)
			}
		}
	}

	func fetchOutcome(sample: HKSample, deletedSample: HKSample?, task: OCKHealthKitTask, carePlanId: String) -> CHOutcome? {
		var outcome = CHOutcome(sample: sample, task: task, carePlanId: carePlanId, deletedSample: nil)
		if let deleted = deletedSample, let existing = try? dbFindFirstOutcome(sample: deleted) {
			outcome?.remoteId = existing.remoteId
			outcome?.updatedDate = Date()
		}
		return outcome
	}

	func fetchOutcomes(taskId: UUID, startDate: Date, endDate: Date, callbackQueue: DispatchQueue, completion: @escaping (Result<[OCKOutcome], OCKStoreError>) -> Void) {
		fetchOutcomes(taskIds: [taskId], startDate: startDate, endDate: endDate, callbackQueue: callbackQueue, completion: completion)
	}

	func fetchOutcomes(taskIds: [UUID], startDate: Date, endDate: Date, callbackQueue: DispatchQueue, completion: @escaping (Result<[OCKOutcome], OCKStoreError>) -> Void) {
		let dateInterval = DateInterval(start: startDate, end: endDate)
		var query = OCKOutcomeQuery(dateInterval: dateInterval)
		query.taskUUIDs = taskIds
		store.fetchOutcomes(query: query, callbackQueue: callbackQueue, completion: completion)
	}

	func fetchOutcomes(taskId: UUID, startDate: Date, endDate: Date) async throws -> [OCKOutcome] {
		try await fetchOutcomes(taskIds: [taskId], startDate: startDate, endDate: endDate)
	}

	func fetchOutcomes(taskIds: [UUID], startDate: Date, endDate: Date) async throws -> [OCKOutcome] {
		let dateInterval = DateInterval(start: startDate, end: endDate)
		var query = OCKOutcomeQuery(dateInterval: dateInterval)
		query.taskUUIDs = taskIds
		return try await store.fetchOutcomes(query: query)
	}
}

// CoreData
extension CareManager {
	func dbFindFirstOutcome(uuid: UUID) throws -> CHOutcome? {
		try dbFindFirst(uuid: uuid)?.outcome
	}

	func dbFindFirst(uuid: UUID) throws -> MappedOutcome? {
		try MappedOutcome.findFirst(inContext: dbStore.managedObjectContext, uuid: uuid)
	}

	func dbFindFirstOutcome(sample: HKSample) throws -> CHOutcome? {
		try dbFindFirstOutcome(sampleId: sample.uuid)
	}

	func dbFindFirstOutcome(sampleId: UUID) throws -> CHOutcome? {
		try dbFindFirst(sampleId: sampleId)?.outcome
	}

	func dbFindFirst(sampleId: UUID) throws -> MappedOutcome? {
		try MappedOutcome.findFirst(inContext: dbStore.managedObjectContext, sampleId: sampleId)
	}

	func dbInsert(outcomes: [CHOutcome]) throws -> [MappedOutcome] {
		let result = outcomes.compactMap { outcome -> MappedOutcome? in
			do {
				let result = try dbInsert(outcome: outcome, shouldSave: false)
				return result
			} catch {
				ALog.error("unable to insert outcome \(outcome)")
				return nil
			}
		}
		if !result.isEmpty {
			dbStore.saveContext()
		}
		return result
	}

	@discardableResult
	func dbInsert(outcome: CHOutcome, shouldSave: Bool = true) throws -> MappedOutcome? {
		var mappedOutcome = try MappedOutcome.findFirst(inContext: dbStore.managedObjectContext, uuid: outcome.uuid)
		if mappedOutcome != nil {
			mappedOutcome?.outcome = outcome
			mappedOutcome?.createdDate = outcome.createdDate
			mappedOutcome?.remoteId = outcome.remoteId
			mappedOutcome?.deletedDate = outcome.deletedDate
			mappedOutcome?.updatedDate = outcome.updatedDate
		} else {
			mappedOutcome = MappedOutcome(outcome: outcome, insertInto: dbStore.managedObjectContext)
		}
		if shouldSave {
			dbStore.saveContext()
		}
		return mappedOutcome
	}

	func dbDeleteFirst(outcome: CHOutcome) throws {
		if let existing = try MappedOutcome.findFirst(inContext: dbStore.managedObjectContext, uuid: outcome.uuid) {
			dbStore.managedObjectContext.delete(existing)
			dbStore.saveContext()
		}
	}

	func dbDeleteFirst(uuid: UUID) throws -> CHOutcome? {
		guard let outcome = try MappedOutcome.findFirst(inContext: dbStore.managedObjectContext, uuid: uuid) else {
			throw AllieError.missing("Could not find outcome")
		}
		dbStore.managedObjectContext.delete(outcome)
		dbStore.saveContext()
		return outcome.outcome
	}

	func dbDeleteFirst(sample: HKSample) throws -> CHOutcome? {
		try dbDeleteFirst(sampleId: sample.uuid)
	}

	func dbDeleteFirst(sampleId: UUID) throws -> CHOutcome? {
		guard let outcome = try MappedOutcome.findFirst(inContext: dbStore.managedObjectContext, sampleId: sampleId) else {
			throw AllieError.missing("Could not find outcome")
		}
		dbStore.managedObjectContext.delete(outcome)
		dbStore.saveContext()
		return outcome.outcome
	}
}

extension CareManager {
	func upload(anyOutcomes outcomes: [OCKAnyOutcome]) {
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
						let chOutcome = CHOutcome(hkOutcome: theOutcome, carePlanID: carePlanId, task: task)
						chOutcomes.append(chOutcome)
					} else if let theOutcome = ockOutcome {
						let chOutcome = CHOutcome(outcome: theOutcome, carePlanID: carePlanId, task: task)
						chOutcomes.append(chOutcome)
					}
				}
				group.leave()
			}

			group.notify(queue: .main) { [weak self] in
				self?.upload(outcomes: chOutcomes, completion: { result in
					if case .failure(let error) = result {
						ALog.error("\(error.localizedDescription)", error: error)
					}
				})
			}
		}
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
			}.tryMap { [weak self] task -> [CHOutcome] in
				guard let carePlanId = task.carePlanId else {
					throw AllieError.missing("Care Plan Id Missing")
				}
				let outcomes = samples.compactMap { sample in
					self?.fetchOutcome(sample: sample, deletedSample: nil, task: task, carePlanId: carePlanId)
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
		let allieOutcome = CHOutcome(outcome: outcome, carePlanID: carePlanId, task: task)
		networkAPI.post(outcomes: [allieOutcome])
			.sink { completion in
				switch completion {
				case .failure(let error):
					ALog.error("\(error.localizedDescription)")
				case .finished:
					ALog.info("Uploaded the outcome")
				}
			} receiveValue: { [weak self] response in
				do {
					_ = try self?.dbInsert(outcomes: response.outcomes)
				} catch {
					ALog.error("\((error as NSError).debugDescription)", error: error)
				}
			}.store(in: &cancellables)
	}

	func upload(outcomes: [CHOutcome], completion: @escaping AllieResultCompletion<[CHOutcome]>) {
		guard !outcomes.isEmpty else {
			completion(.success([]))
			return
		}
		networkAPI.post(outcomes: outcomes)
			.sink { completionResult in
				if case .failure(let error) = completionResult {
					completion(.failure(error))
				}
			} receiveValue: { [weak self] response in
				guard let strongSelf = self else {
					return
				}
				do {
					_ = try strongSelf.dbInsert(outcomes: response.outcomes)
					completion(.success(response.outcomes))
				} catch {
					ALog.error("\((error as NSError).debugDescription)", error: error)
					completion(.failure(error))
				}
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

	func save(outcomes: [CHOutcome]) throws -> [OCKOutcome] {
		_ = try dbInsert(outcomes: outcomes)
		let ockOutomes = outcomes.compactMap { outcome -> OCKOutcome? in
			OCKOutcome(outcome: outcome)
		}
		return ockOutomes
	}

	func save(outcomes: [CHOutcome], completion: @escaping AllieResultCompletion<[OCKOutcome]>) {
		do {
			_ = try dbInsert(outcomes: outcomes)
			let ockOutomes = outcomes.compactMap { outcome -> OCKOutcome? in
				OCKOutcome(outcome: outcome)
			}
			completion(.success(ockOutomes))
		} catch {
			completion(.failure(error))
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
