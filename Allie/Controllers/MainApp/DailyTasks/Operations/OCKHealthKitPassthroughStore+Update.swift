//
//  OCKHealthKitPassthroughStore+Update.swift
//  Allie
//
//  Created by Waqar Malik on 2/2/21.
//

import CareKitStore
import Foundation

extension OCKHealthKitPassthroughStore {
	func createOrUpdateTask(_ task: OCKHealthKitTask, callbackQueue: DispatchQueue = .main, completion: ((Result<OCKHealthKitTask, OCKStoreError>) -> Void)? = nil) {
		fetchAnyTask(withID: task.id, callbackQueue: callbackQueue) { [weak self] result in
			switch result {
			case .failure:
				self?.addTask(task, callbackQueue: callbackQueue, completion: completion)
			case .success:
				self?.updateTask(task, callbackQueue: callbackQueue, completion: completion)
			}
		}
	}

	func createOrUpdateTasks(_ tasks: [OCKHealthKitTask], callbackQueue: DispatchQueue = .main, completion: ((Result<[OCKHealthKitTask], OCKStoreError>) -> Void)? = nil) {
		let queue = DispatchQueue.global(qos: .background)
		var errors: [String: Error] = [:]
		var updatedTasks: [OCKHealthKitTask] = []
		queue.async { [weak self] in
			let group = DispatchGroup()
			for task in tasks {
				group.enter()
				self?.createOrUpdateTask(task, callbackQueue: queue, completion: { result in
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
