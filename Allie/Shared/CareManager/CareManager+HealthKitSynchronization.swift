//
//  CareManager+HealthKitSynchronization.swift
//  Allie
//
//  Created by Waqar Malik on 4/21/21.
//

import CareKitStore
import HealthKit

extension CareManager {
	func startHealthKitSynchronization() {
		stopHealthKitSynchronization()
		timerCancellable = Timer.publish(every: Constants.outcomeUploadIimeInteval, tolerance: 5.0, on: .current, in: .common, options: nil)
			.autoconnect()
			.sink { _ in
				self.synchronizeHealthKitOutcomes()
			}
	}

	var isHealthKitSynchronizationSarted: Bool {
		timerCancellable == nil
	}

	func stopHealthKitSynchronization() {
		timerCancellable?.cancel()
		timerCancellable = nil
		isSynchronizingOutcomes = false
	}

	func synchronizeHealthKitOutcomes() {
		guard isSynchronizingOutcomes == false else {
			return
		}

		healthKitStore.fetchAnyTasks(query: OCKTaskQuery(for: Date()), callbackQueue: .main) { [weak self] tasksResult in
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
				self?.synchronizeHealthKitOutcomes(tasks: tasks, completion: { _ in
					self?.isSynchronizingOutcomes = false
				})
			}
		}
	}

	func synchronizeHealthKitOutcomes(tasks: [OCKHealthKitTask], completion: @escaping ((Bool) -> Void)) {
		let now = Date()
		let lastUpdatedDate = UserDefaults.standard.lastObervationUploadDate
		var allSamples: [HKQuantityTypeIdentifier: [HKSample]] = [:]
		let group = DispatchGroup()
		for task in tasks {
			let linkage = task.healthKitLinkage
			if let quantityType = HKObjectType.quantityType(forIdentifier: linkage.quantityIdentifier) {
				group.enter()
				HealthKitManager.shared.queryHealthData(initialUpload: false, sampleType: quantityType, from: lastUpdatedDate, to: now) { sucess, samples in
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

		APIClient.client.postOutcome(outcomes: outcomes)
			.sink { completionResult in
				switch completionResult {
				case .failure(let error):
					ALog.error("\(error.localizedDescription)")
					completion(false)
				case .finished:
					break
				}
			} receiveValue: { response in
				if !response.outcomes.isEmpty {
					ALog.info("\(response.outcomes.count) outcomes saved to server")
					self.save(outcomes: response.outcomes)
						.sink { completionResult in
							switch completionResult {
							case .failure(let error):
								ALog.error("\(error.localizedDescription)")
                            case .finished:
								break
							}
							completion(true)
						} receiveValue: { value in
							ALog.info("\(value.count) outcomes saved to store")
						}.store(in: &self.cancellables)
				}
			}.store(in: &cancellables)
	}
}
