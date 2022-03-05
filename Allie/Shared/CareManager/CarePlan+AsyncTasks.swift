//
//  CarePlan+AsyncTasks.swift
//  Allie
//
//  Created by Waqar Malik on 2/24/22.
//

import CareKitStore
import CareModel
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

	func process(tasks: [CHTask], excludesTasksWithNoEvents: Bool = true, carePlan: CHCarePlan?, existingTasks: [String: CHTask]) async throws -> [CHTask] {
		var updateTasks: [CHTask] = []
		for task in tasks {
			if task.shouldDelete {
				continue
			}
			// if the task exists and they are equal then we just skip it.
			if let existingTask = existingTasks[task.id], existingTask == task {
				continue
			}

			do {
				let updated = try await process(task: task, excludesTasksWithNoEvents: excludesTasksWithNoEvents, carePlan: carePlan)
				updateTasks.append(updated)
			} catch {
				ALog.error("Unable to update the task \(task.id) \(error as NSError)\n")
			}
		}
		return updateTasks
	}

	func deleteTasks(exclude: [String], carePlans: [String]) async throws {
		let tasksQuery = OCKTaskQuery(for: Date())
		let allTasks = try await store.fetchAnyTasks(query: tasksQuery, queue: processingQueue)
		let filtered = allTasks.filter { task in
			if let ockTask = task as? OCKTask, let carePlanId = ockTask.carePlanId, !carePlans.isEmpty {
				return !carePlans.contains(carePlanId)
			}
			if let hkTask = task as? OCKHealthKitTask, let carePlanId = hkTask.carePlanId, !carePlans.isEmpty {
				return !carePlans.contains(carePlanId)
			}
			return !exclude.contains(task.id)
		}

		guard !filtered.isEmpty else {
			return
		}
		_ = try await store.deleteAnyTasks(filtered)
	}
}

public extension OCKAnyReadOnlyTaskStore {
	func fetchAnyTasks(query: OCKTaskQuery, queue: DispatchQueue) async throws -> [OCKAnyTask] {
		try await withCheckedThrowingContinuation { continuation in
			fetchAnyTasks(query: query, callbackQueue: queue, completion: continuation.resume)
		}
	}
}
