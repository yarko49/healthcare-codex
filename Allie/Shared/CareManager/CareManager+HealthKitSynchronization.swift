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
		guard isSynchronizingOutcomes == false, patient != nil else {
			return
		}

		isSynchronizingOutcomes = true
		uploadQueue.async { [weak self] in
			guard let strongSelf = self else {
				self?.isSynchronizingOutcomes = false
				return
			}
			strongSelf.fetchAllHealthKitTasks(callbackQueue: strongSelf.uploadQueue) { [weak self] success in
				self?.isSynchronizingOutcomes = false
				if !success {
					ALog.error("Upload failed")
				}
			}
		}
	}

	func fetchAllHealthKitTasks(callbackQueue: DispatchQueue, completion: @escaping ((Bool) -> Void)) {
		healthKitStore.fetchAnyTasks(query: OCKTaskQuery(), callbackQueue: callbackQueue) { [weak self] tasksResult in
			switch tasksResult {
			case .failure(let error):
				ALog.error("\(error.localizedDescription)")
				completion(false)
			case .success(let newTasks):
				let tasks = newTasks.compactMap { anyTask in
					anyTask as? OCKHealthKitTask
				}
				guard !tasks.isEmpty else {
					completion(true)
					return
				}
				let lastUpdatedDate = UserDefaults.standard.lastObervationUploadDate
				let endDate = Date()
				self?.synchronizeHealthKitOutcomes(tasks: tasks, startDate: lastUpdatedDate, endDate: endDate, callbackQueue: callbackQueue, completion: { result in
					if result {
						UserDefaults.standard.lastObervationUploadDate = endDate
					}
					completion(result)
				})
			}
		}
	}

	func synchronizeHealthKitOutcomes(tasks: [OCKHealthKitTask], startDate: Date, endDate: Date, callbackQueue: DispatchQueue, completion: @escaping ((Bool) -> Void)) {
		var allSamples: [HKQuantityTypeIdentifier: [HKSample]] = [:]
		let group = DispatchGroup()
		for task in tasks {
			let linkage = task.healthKitLinkage
			if let quantityType = HKObjectType.quantityType(forIdentifier: linkage.quantityIdentifier) {
				group.enter()
				HealthKitManager.shared.queryHealthData(sampleType: quantityType, startDate: startDate, endDate: endDate) { sucess, samples in
					if sucess {
						allSamples[linkage.quantityIdentifier] = samples
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
			self?.uploadSamples(samples: allSamples, tasks: tasks, callbackQueue: callbackQueue, completion: completion)
		}
	}

	func uploadSamples(samples: [HKQuantityTypeIdentifier: [HKSample]], tasks: [OCKHealthKitTask], callbackQueue: DispatchQueue, completion: @escaping ((Bool) -> Void)) {
		var outcomes: [Outcome] = []
		for task in tasks {
			guard let carePlanId = task.carePlanId else {
				continue
			}
			let linkage = task.healthKitLinkage
			if let taskSamples = samples[linkage.quantityIdentifier] {
				let taskOucomes = taskSamples.compactMap { sample in
					Outcome(sample: sample, task: task, carePlanId: carePlanId)
				}
				outcomes.append(contentsOf: taskOucomes)
			}
		}

		guard !outcomes.isEmpty else {
			completion(false)
			return
		}
		upload(outcomes: outcomes, callbackQueue: callbackQueue, completion: completion)
	}

	func upload(outcomes: [Outcome], callbackQueue: DispatchQueue, completion: @escaping ((Bool) -> Void)) {
		let chunkedOutcomes = outcomes.chunked(into: Constants.maximumUploadOutcomesPerCall)
		let group = DispatchGroup()
		var responseOutcomes: [Outcome] = []
		for chunkOutcome in chunkedOutcomes {
			group.enter()
			APIClient.shared.post(outcomes: chunkOutcome)
				.sink { completionResult in
					switch completionResult {
					case .failure(let error):
						ALog.error("\(error.localizedDescription)")
						completion(false)
						group.leave()
					case .finished:
						break
					}
				} receiveValue: { carePlanResponse in
					responseOutcomes.append(contentsOf: carePlanResponse.outcomes)
					group.leave()
				}.store(in: &cancellables)
		}

		group.notify(queue: callbackQueue) { [weak self] in
			self?.process(outcomes: responseOutcomes, completion: completion)
		}
	}

	func backgroundUpload(outcomes: [Outcome], completion: @escaping ((Bool) -> Void)) {
		let manager: DataUploadManager<CarePlanResponse> = DataUploadManager(route: .postOutcomes(outcomes: outcomes)) { [weak self] result in
			switch result {
			case .failure(let error):
				ALog.error("\(error.localizedDescription)")
				completion(false)
			case .success(let carePlanResponse):
				self?.process(outcomes: carePlanResponse.outcomes, completion: completion)
			}
		}
		outcomeUploaders.insert(manager)
		do {
			try manager.start()
		} catch {
			ALog.error("Unable to start the upload \(error.localizedDescription)")
		}
	}

	func process(outcomes: [Outcome], completion: ((Bool) -> Void)?) {
		if !outcomes.isEmpty {
			ALog.info("\(outcomes.count) outcomes saved to server")
			save(outcomes: outcomes)
				.sink { completionResult in
					switch completionResult {
					case .failure(let error):
						ALog.error("\(error.localizedDescription)")
					case .finished:
						break
					}
					completion?(true)
				} receiveValue: { value in
					ALog.info("\(value.count) outcomes saved to store")
				}.store(in: &cancellables)
		} else {
			completion?(false)
		}
	}
}
