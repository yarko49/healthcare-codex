//
//  HealthKitAddTasksOperation.swift
//  Allie
//
//  Created by Waqar Malik on 1/15/21.
//

import CareKitStore
import Foundation

protocol HealthKitTasksResultProvider {
	var tasks: [OCKHealthKitTask]? { get }
}

class HealthKitAddTasksOperation: AsynchronousOperation, HealthKitTasksResultProvider {
	var tasks: [OCKHealthKitTask]?
	private var store: OCKHealthKitPassthroughStore
	private var newTasks: [OCKHealthKitTask]
	private var completionHandler: OCKResultClosure<[OCKHealthKitTask]>?

	init(store: OCKHealthKitPassthroughStore, newTasks: [OCKHealthKitTask] = [], callbackQueue: DispatchQueue = .main, completion: OCKResultClosure<[OCKHealthKitTask]>? = nil) {
		self.store = store
		self.newTasks = newTasks
		self.completionHandler = completion
		super.init()
		self.callbackQueue = callbackQueue
	}

	private var error: OCKStoreError?

	override func start() {
		guard !newTasks.isEmpty else {
			complete()
			return
		}
		store.createOrUpdateTasks(newTasks, callbackQueue: .main) { [weak self] result in
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
