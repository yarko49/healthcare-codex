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

		let group = DispatchGroup()

		var tasks: [OCKHealthKitTask] = []
		group.enter()
		healthKitStore.fetchTasks(query: OCKTaskQuery()) { tasksResult in
			switch tasksResult {
			case .failure(let error):
				ALog.error("\(error.localizedDescription)")
			case .success(let newTasks):
				tasks = newTasks
			}
			group.leave()
		}

		group.notify(queue: .main) { [weak self] in
			guard !tasks.isEmpty else {
				self?.isSynchronizingOutcomes = false
				return
			}
			self?.synchronizeHealthKitOutcomes(tasks: tasks, completion: { _ in
				self?.isSynchronizingOutcomes = false
			})
		}
	}

	func synchronizeHealthKitOutcomes(tasks: [OCKHealthKitTask], completion: @escaping ((Bool) -> Void)) {
		let now = Date()
		let lastUpdatedDate = UserDefaults.standard.lastObervationUploadDate
		guard lastUpdatedDate < now else {
			completion(true)
			return
		}

		var allSamples: [HKQuantityTypeIdentifier: [HKSample]] = [:]
		let group = DispatchGroup()
		for task in tasks {
			if let quantityType = HKObjectType.quantityType(forIdentifier: task.healthKitLinkage.quantityIdentifier) {
				group.enter()
				HealthKitManager.shared.queryHealthData(initialUpload: false, sampleType: quantityType, from: lastUpdatedDate, to: now) { sucess, samples in
					if sucess {
						allSamples[task.healthKitLinkage.quantityIdentifier] = samples
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
			if let taskSamples = samples[task.healthKitLinkage.quantityIdentifier] {
				let taskOucomes = taskSamples.compactMap { sample in
					Outcome(sample: sample, task: task)
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
