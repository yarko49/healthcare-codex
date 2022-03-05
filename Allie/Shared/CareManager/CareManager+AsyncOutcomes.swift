//
//  CareManager+AsyncOutcomes.swift
//  Allie
//
//  Created by Waqar Malik on 2/24/22.
//

import CareKit
import CareKitStore
import CareModel
import Combine
import CoreData
import Foundation
import HealthKit

extension CareManager {
	func upload(anyOutcomes outcomes: [OCKAnyOutcome]) async throws -> [CHOutcome] {
		guard !outcomes.isEmpty else {
			return []
		}

		var chOutcomes: [CHOutcome] = []
		for outcome in outcomes {
			let hkOutcome = outcome as? OCKHealthKitOutcome
			let ockOutcome = outcome as? OCKOutcome
			guard let taskUUID = hkOutcome?.taskUUID ?? ockOutcome?.taskUUID else {
				continue
			}
			var taskQuery = OCKTaskQuery()
			taskQuery.uuids.append(taskUUID)
			let tasks = try await store.fetchTasks(query: taskQuery)
			guard let task = tasks.first, let carePlanId = task.userInfo?["carePlanId"] else {
				continue
			}
			if let theOutcome = hkOutcome {
				let chOutcome = CHOutcome(hkOutcome: theOutcome, carePlanID: carePlanId, task: task)
				chOutcomes.append(chOutcome)
			} else if let theOutcome = ockOutcome {
				let chOutcome = CHOutcome(outcome: theOutcome, carePlanID: carePlanId, task: task)
				chOutcomes.append(chOutcome)
			}
		}

		let uploaded = try await upload(outcomes: chOutcomes)
		return uploaded
	}

	func upload(samples: [HKSample], quantityIdentifier: HKQuantityTypeIdentifier) async throws -> [CHOutcome] {
		guard !samples.isEmpty else {
			return []
		}
		let tasks = try await healthKitStore.fetchTasks(quantityIdentifier: quantityIdentifier)
		var unique: [String: OCKHealthKitTask] = [:]
		tasks.forEach { task in
			unique[task.id] = task
		}

		let filteredTasks: [OCKHealthKitTask] = unique.reduce([]) { partialResult, item in
			var result = partialResult
			result.append(item.value)
			return result
		}
		guard let task = filteredTasks.first, filteredTasks.count == 1 else {
			throw AllieError.invalid("More than one task with same HKQuantityTypeIdentifier = \(unique.keys)")
		}
		guard let carePlanId = task.carePlanId else {
			throw AllieError.missing("Care Plan Id Missing")
		}
		let outcomes = samples.compactMap { sample in
			fetchOutcome(sample: sample, deletedSample: nil, task: task, carePlanId: carePlanId)
		}
		let uploadResponse = try await networkAPI.post(outcomes: outcomes)
		return uploadResponse.outcomes
	}

	func upload(outcome: OCKOutcome, task: OCKTask, carePlanId: String) async throws -> CHOutcome {
		let allieOutcome = CHOutcome(outcome: outcome, carePlanID: carePlanId, task: task)
		let outcomes = try await upload(outcomes: [allieOutcome])
		return outcomes.first ?? allieOutcome
	}

	func upload(outcomes: [CHOutcome]) async throws -> [CHOutcome] {
		guard !outcomes.isEmpty else {
			return []
		}
		let carePlanResponse = try await networkAPI.post(outcomes: outcomes)
		_ = try dbInsert(outcomes: carePlanResponse.outcomes)
		return carePlanResponse.outcomes
	}

	func save(outcomes: [CHOutcome]) async throws -> [OCKOutcome] {
		_ = try dbInsert(outcomes: outcomes)
		let ockOutomes = outcomes.compactMap { outcome -> OCKOutcome? in
			OCKOutcome(outcome: outcome)
		}
		return ockOutomes
	}

	func deleteOutcomes(task: CHTask) async throws -> [OCKOutcome] {
		let dateInterval = DateInterval(start: task.effectiveDate, end: Date.distantFuture)
		var outcomeQuery = OCKOutcomeQuery(dateInterval: dateInterval)
		outcomeQuery.taskIDs = [task.id]
		let outcomes = try await store.fetchOutcomes(query: outcomeQuery)
		let deletedOutcomes = try await store.deleteOutcomes(outcomes)
		return deletedOutcomes
	}
}
