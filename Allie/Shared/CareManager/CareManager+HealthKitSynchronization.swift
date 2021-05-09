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

		healthKitStore.fetchAnyTasks(query: OCKTaskQuery(), callbackQueue: .main) { [weak self] tasksResult in
			switch tasksResult {
			case .failure(let error):
				ALog.error("\(error.localizedDescription)")
				self?.isSynchronizingOutcomes = false
			case .success(let newTasks):
				let tasks = newTasks.compactMap { anyTask in
					anyTask as? OCKHealthKitTask
				}
				guard !tasks.isEmpty else {
					self?.isSynchronizingOutcomes = false
					return
				}
				let lastUpdatedDate = UserDefaults.standard.lastObervationUploadDate
				let endDate = Date()
				self?.synchronizeHealthKitOutcomes(tasks: tasks, startDate: lastUpdatedDate, endDate: endDate, completion: { result in
					self?.isSynchronizingOutcomes = false
					if result {
						UserDefaults.standard.lastObervationUploadDate = endDate
					}
				})
			}
		}
	}

	func synchronizeHealthKitOutcomes(tasks: [OCKHealthKitTask], startDate: Date, endDate: Date, completion: @escaping ((Bool) -> Void)) {
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

		group.notify(queue: .main) { [weak self] in
			guard !allSamples.isEmpty else {
				completion(false)
				return
			}
			self?.uploadSamples(samples: allSamples, tasks: tasks, completion: completion)
		}
	}

	func uploadSamples(samples: [HKQuantityTypeIdentifier: [HKSample]], tasks: [OCKHealthKitTask], completion: @escaping ((Bool) -> Void)) {
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
		upload(outcomes: outcomes, completion: completion)
	}

	func upload(outcomes: [Outcome], completion: @escaping ((Bool) -> Void)) {
		APIClient.shared.post(outcomes: outcomes)
			.sink { completionResult in
				switch completionResult {
				case .failure(let error):
					ALog.error("\(error.localizedDescription)")
					completion(false)
				case .finished:
					break
				}
			} receiveValue: { [weak self] carePlanResponse in
				self?.processOutcomes(carePlanResponse: carePlanResponse, completion: completion)
			}.store(in: &cancellables)
	}

	func backgroundUpload(outcomes: [Outcome], completion: @escaping ((Bool) -> Void)) {
		let manager: DataUploadManager<CarePlanResponse> = DataUploadManager(route: .postOutcomes(outcomes: outcomes)) { [weak self] result in
			switch result {
			case .failure(let error):
				ALog.error("\(error.localizedDescription)")
				completion(false)
			case .success(let carePlanResponse):
				self?.processOutcomes(carePlanResponse: carePlanResponse, completion: completion)
			}
		}
		outcomeUploaders.insert(manager)
		do {
			try manager.start()
		} catch {
			ALog.error("Unable to start the upload \(error.localizedDescription)")
		}
	}

	func processOutcomes(carePlanResponse: CarePlanResponse, completion: ((Bool) -> Void)?) {
		if !carePlanResponse.outcomes.isEmpty {
			ALog.info("\(carePlanResponse.outcomes.count) outcomes saved to server")
			save(outcomes: carePlanResponse.outcomes)
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
