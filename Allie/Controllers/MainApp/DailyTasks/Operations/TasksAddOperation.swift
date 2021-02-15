//
//  TasksAddOperation.swift
//  Allie
//
//  Created by Waqar Malik on 1/15/21.
//

import CareKitStore
import Foundation

protocol TasksResultProvider {
	var tasks: [OCKTask]? { get }
}

class TasksAddOperation: AsynchronousOperation, TasksResultProvider {
	var tasks: [OCKTask]?
	private var store: OCKStore
	private var newTasks: [OCKTask]
	private var completionHandler: OCKResultClosure<[OCKTask]>?

	init(store: OCKStore, newTasks: [OCKTask] = [], callbackQueue: DispatchQueue = .main, completion: OCKResultClosure<[OCKTask]>? = nil) {
		self.store = store
		self.newTasks = newTasks
		self.completionHandler = completion
		super.init()
		self.callbackQueue = callbackQueue
	}

	private var error: OCKStoreError?

	override func main() {
		guard !newTasks.isEmpty else {
			complete()
			return
		}
		var mappedTasks = newTasks
		let carePlans = dependencies.compactMap { (operation) -> [OCKCarePlan]? in
			(operation as? CarePlansResultProvider)?.carePlans
		}.first?.reduce([:]) { (result, plan) -> [String: OCKCarePlan] in
			var newResult = result
			newResult[plan.id] = plan
			return newResult
		}
		if let plans = carePlans {
			mappedTasks = newTasks.map { (task) -> OCKTask in
				guard let carePlanId = task.carePlanId else {
					return task
				}
				var newTask = task
				newTask.carePlanUUID = plans[carePlanId]?.uuid
				return newTask
			}
		}

		store.createOrUpdateTasks(mappedTasks, callbackQueue: callbackQueue) { [weak self] result in
			defer {
				self?.complete()
			}

			switch result {
			case .failure(let error):
				self?.error = error
			case .success(let addedResults):
				self?.tasks = addedResults
			}
		}
	}

	private func complete() {
		guard let handler = completionHandler else {
			finish()
			return
		}
		callbackQueue.async { [weak self] in
			if let results = self?.tasks, self?.error == nil {
				handler(.success(results))
			} else if let error = self?.error {
				handler(.failure(error))
			} else {
				handler(.failure(.addFailed(reason: "Invalid Input Data")))
			}
		}
		finish()
	}
}
