//
//  OCKHealthKitPassthroughStore+Update.swift
//  Allie
//
//  Created by Waqar Malik on 2/2/21.
//

import CareKitStore
import Foundation

// MARK: - HealthKitTasks

extension OCKHealthKitPassthroughStore {
	func addOrUpdate(healthKitTask task: OCKHealthKitTask, callbackQueue: DispatchQueue, completion: ((Result<OCKHealthKitTask, OCKStoreError>) -> Void)? = nil) {
		fetchTask(withID: task.id, callbackQueue: callbackQueue) { [weak self] result in
			switch result {
			case .failure:
				self?.addTask(task, callbackQueue: callbackQueue, completion: completion)
			case .success(let existing):
				let merged = existing.merged(newTask: task)
				self?.updateTask(merged, callbackQueue: callbackQueue, completion: completion)
			}
		}
	}

	func addOrUpdate(healthKitTasks tasks: [OCKHealthKitTask], callbackQueue: DispatchQueue, completion: ((Result<[OCKHealthKitTask], OCKStoreError>) -> Void)? = nil) {
		guard !tasks.isEmpty else {
			completion?(.failure(.updateFailed(reason: "Missing input HealthKit tasks")))
			return
		}
		let queue = DispatchQueue.global(qos: .userInitiated)
		var errors: [String: Error] = [:]
		var updatedTasks: [OCKHealthKitTask] = []
		queue.async { [weak self] in
			let group = DispatchGroup()
			for task in tasks {
				group.enter()
				self?.addOrUpdate(healthKitTask: task, callbackQueue: queue, completion: { result in
					switch result {
					case .failure(let error):
						errors[task.id] = error
					case .success(let updated):
						updatedTasks.append(updated)
					}
					group.leave()
				})
			}
			group.notify(queue: callbackQueue) {
				completion?(.success(updatedTasks))
			}
		}
	}
}
