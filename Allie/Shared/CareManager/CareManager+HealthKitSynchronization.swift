//
//  CareManager+HealthKitSynchronization.swift
//  Allie
//
//  Created by Waqar Malik on 4/21/21.
//

import CareKitStore
import HealthKit

extension CareManager {
	func synchronizeHealthKitOutcomes() {
		guard patient != nil else {
			return
		}

		uploadQueue.async { [weak self] in
			guard let strongSelf = self else {
				return
			}
			strongSelf.fetchAllHealthKitTasks(callbackQueue: strongSelf.uploadQueue) { success in
				if !success {
					ALog.error("Upload failed")
				}
			}
		}
	}

	func fetchAllHealthKitTasks(callbackQueue: DispatchQueue, completion: @escaping BoolCompletion) {
		var query = OCKTaskQuery()
		query.sortDescriptors = [.effectiveDate(ascending: false)]
		healthKitStore.fetchAnyTasks(query: query, callbackQueue: callbackQueue) { [weak self] tasksResult in
			switch tasksResult {
			case .failure(let error):
				ALog.error("\(error.localizedDescription)")
				completion(false)
			case .success(let newTasks):
				let tasks: [OCKHealthKitTask] = newTasks.compactMap { anyTask in
					let hkTask = anyTask as? OCKHealthKitTask
					ALog.trace("nextUUID = \(String(describing: hkTask?.nextVersionUUIDs.count)), effectiveDate = \(anyTask.effectiveDate), createdDate = \(String(describing: hkTask?.createdDate)), updatedDate = \(String(describing: hkTask?.createdDate))")
					return hkTask
				}
				guard !tasks.isEmpty else {
					completion(true)
					return
				}
				let group = DispatchGroup()
				let uniqueTasks: [String: OCKHealthKitTask] = tasks.reduce([:]) { partial, task in
					if let existing = partial[task.id], !existing.nextVersionUUIDs.isEmpty, task.nextVersionUUIDs.isEmpty {
						var newResult = partial
						newResult[task.id] = task
						return newResult
					} else {
						var newResult = partial
						newResult[task.id] = task
						return newResult
					}
				}

				for (_, task) in uniqueTasks {
					if task.healthKitLinkage.quantityIdentifier == .stepCount {
						continue
					}
					group.enter()
					let operation = OutcomesUploadOperation(task: task, chunkSize: Constants.maximumUploadOutcomesPerCall, callbackQueue: callbackQueue) { operationResult in
						switch operationResult {
						case .failure(let error):
							ALog.error("Uploading outcomes \(error.localizedDescription)", error: error)
						case .success(let outcomes):
							ALog.trace("Uploaded \(outcomes.count) outcomes")
						}
						group.leave()
					}
					self?[uploadOperationQueue: task.healthKitLinkage.quantityIdentifier.rawValue].addOperation(operation)
				}
				group.notify(queue: callbackQueue) {
					completion(true)
				}
			}
		}
	}

	func synchronizeHealthKitOutcomes(tasks: [OCKHealthKitTask], callbackQueue: DispatchQueue, completion: @escaping BoolCompletion) {
		var allSamples: [HKQuantityTypeIdentifier: [HKSample]] = [:]
		let group = DispatchGroup()
		let endDate = Date()
		for task in tasks {
			let linkage = task.healthKitLinkage
			let startDate = UserDefaults.standard[lastOutcomesUploadDate: linkage.quantityIdentifier.rawValue]
			if let quantityType = HKObjectType.quantityType(forIdentifier: linkage.quantityIdentifier) {
				group.enter()
				HealthKitManager.shared.queryHealthData(quantityType: quantityType, startDate: startDate, endDate: endDate, options: []) { result in
					switch result {
					case .failure(let error):
						ALog.error("\(error.localizedDescription)")
					case .success(let samples):
						var existing = allSamples[linkage.quantityIdentifier] ?? []
						existing.append(contentsOf: samples)
						allSamples[linkage.quantityIdentifier] = existing
					}
					group.leave()
				}
			}
		}

		group.notify(queue: callbackQueue) { [weak self] in
			guard !allSamples.isEmpty else {
				completion(false)
				return
			}
			self?.upload(samples: allSamples, tasks: tasks, endDate: endDate, callbackQueue: callbackQueue, completion: completion)
		}
	}

	func upload(samples: [HKQuantityTypeIdentifier: [HKSample]], tasks: [OCKHealthKitTask], endDate: Date, callbackQueue: DispatchQueue, completion: @escaping BoolCompletion) {
		let group = DispatchGroup()
		for task in tasks {
			guard let carePlanId = task.carePlanId else {
				continue
			}
			let linkage = task.healthKitLinkage
			guard let taskSamples = samples[linkage.quantityIdentifier] else {
				continue
			}
			let taskOucomes = taskSamples.compactMap { sample in
				Outcome(sample: sample, task: task, carePlanId: carePlanId)
			}
			if taskOucomes.isEmpty {
				continue
			}
			group.enter()
			upload(outcomes: taskOucomes, callbackQueue: callbackQueue) { [weak self] result in
				switch result {
				case .success(let uploadedOutcomes):
					self?.process(outcomes: uploadedOutcomes, completion: nil)
					UserDefaults.standard[lastOutcomesUploadDate: linkage.quantityIdentifier.rawValue] = endDate
				case .failure(let error):
					ALog.error("Unable to upload outcomes for identifier \(linkage.quantityIdentifier)", error: error)
				}
				group.leave()
			}
		}

		group.notify(queue: callbackQueue) {
			completion(true)
		}
	}

	func upload(outcomes: [Outcome], callbackQueue: DispatchQueue, completion: @escaping ((Result<[Outcome], Error>) -> Void)) {
		let chunkedOutcomes = outcomes.chunked(into: Constants.maximumUploadOutcomesPerCall)
		let group = DispatchGroup()
		var responseOutcomes: [Outcome] = []
		var errors: [Error] = []
		for chunkOutcome in chunkedOutcomes {
			group.enter()
			APIClient.shared.post(outcomes: chunkOutcome)
				.sink { completionResult in
					switch completionResult {
					case .failure(let error):
						errors.append(error)
						group.leave()
					case .finished:
						break
					}
				} receiveValue: { carePlanResponse in
					responseOutcomes.append(contentsOf: carePlanResponse.outcomes)
					group.leave()
				}.store(in: &cancellables)
		}

		group.notify(queue: callbackQueue) {
			if errors.isEmpty {
				completion(.success(responseOutcomes))
			} else {
				completion(.failure(errors[0]))
			}
		}
	}

	func process(outcomes: [Outcome], completion: BoolCompletion?) {
		guard !outcomes.isEmpty else {
			completion?(true)
			return
		}
		ALog.trace("\(outcomes.count) outcomes saved to server")
		save(outcomes: outcomes)
			.sink { completionResult in
				switch completionResult {
				case .failure(let error):
					ALog.error("\(error.localizedDescription)")
					completion?(false)
				case .finished:
					break
				}
				completion?(true)
			} receiveValue: { values in
				completion?(true)
				ALog.trace("\(values.count) outcomes saved to store")
			}.store(in: &cancellables)
	}
}
