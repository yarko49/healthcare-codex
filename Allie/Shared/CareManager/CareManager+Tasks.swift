//
//  CareManager+Tasks.swift
//  Allie
//
//  Created by Waqar Malik on 9/11/21.
//

import CareKitStore
import Foundation

extension CareManager {
	func process(healthKitTask: OCKHealthKitTask, shouldDelete: Bool = false) async throws -> OCKHealthKitTask {
		do {
			let existingTask = try await healthKitStore.fetchTask(withID: healthKitTask.id)
			if shouldDelete {
				let deltedTask = try await healthKitStore.deleteTask(existingTask)
				return deltedTask
			} else {
				let merged = existingTask.merged(new: healthKitTask)
				let newTask = try await healthKitStore.updateTask(merged)
				return newTask
			}
		} catch {
			let newTask = try await healthKitStore.addTask(healthKitTask)
			return newTask
		}
	}

	func process(task: OCKTask) async throws -> OCKTask {
		do {
			let existingTask = try await store.fetchTask(withID: task.id)
			if task.shouldDelete {
				let deletedTask = try await store.deleteTask(existingTask)
				return deletedTask
			} else {
				let merged = existingTask.merged(new: task)
				let newTask = try await store.updateTask(merged)
				return newTask
			}
		} catch {
			let newTask = try await store.addTask(task)
			return newTask
		}
	}

	func process(task: CHTask, excludesTasksWithNoEvents: Bool = true, carePlan: CHCarePlan?) async throws -> CHTask {
		var updatedTask = task
		if task.healthKitTask != nil {
			var healthKitTask = OCKHealthKitTask(task: task)
			healthKitTask.carePlanUUID = carePlan?.uuid
			healthKitTask.carePlanId = carePlan?.id
			let updated = try await process(healthKitTask: healthKitTask, shouldDelete: task.shouldDelete)
			updatedTask.uuid = updated.uuid
		} else {
			var ockTask = OCKTask(task: task)
			ockTask.carePlanUUID = carePlan?.uuid
			ockTask.carePlanId = carePlan?.id
			let updated = try await process(task: ockTask)
			updatedTask.uuid = updated.uuid
		}

		return updatedTask
	}

	func process(tasks: [CHTask], excludesTasksWithNoEvents: Bool = true, carePlan: CHCarePlan?) async throws -> [CHTask] {
		var updateTasks: [CHTask] = []
		for task in tasks {
			do {
				let updated = try await process(task: task, excludesTasksWithNoEvents: excludesTasksWithNoEvents, carePlan: carePlan)
				updateTasks.append(updated)
			} catch {
				ALog.error("Unable to update the task \(error as NSError)\n")
			}
		}
		return updateTasks
	}

	func syncProcessRegular(tasks: [OCKTask], excludesTasksWithNoEvents: Bool = true, carePlan: OCKCarePlan?, queue: DispatchQueue) -> [OCKTask] {
		var query = OCKTaskQuery(for: Date())
		query.excludesTasksWithNoEvents = excludesTasksWithNoEvents
		return tasks
	}

	func syncProcessHealthKit(tasks: [OCKHealthKitTask], excludesTasksWithNoEvents: Bool = true, carePlan: OCKCarePlan?, queue: DispatchQueue) -> [OCKHealthKitTask] {
		var query = OCKTaskQuery(for: Date())
		query.excludesTasksWithNoEvents = excludesTasksWithNoEvents
		return tasks
	}

	func synchronizeOutcomes(carePlanId: String, tasks: [String], completion: @escaping AllieResultCompletion<Bool>) {
		guard !tasks.isEmpty else {
			completion(.success(false))
			return
		}
		var errors: [Error] = []
		let group = DispatchGroup()
		for task in tasks {
			group.enter()
			synchronizeOutcomes(carePlanId: carePlanId, taskId: task) { downloadResult in
				if case .failure(let error) = downloadResult {
					errors.append(error)
					ALog.error("Unable to synchronize outcomes for task \(task), carePlan = \(carePlanId)", error: error)
				}
				group.leave()
			}
		}

		group.notify(queue: .main) {
			completion(errors.isEmpty ? .success(true) : .failure(AllieError.compound(errors)))
		}
	}
}
