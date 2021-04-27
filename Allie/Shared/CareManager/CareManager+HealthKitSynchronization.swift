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
		var carePlan: OCKCarePlan?
		group.enter()
		store.fetchAnyCarePlans(query: OCKCarePlanQuery(for: Date()), callbackQueue: .main) { carePlanResult in
			switch carePlanResult {
			case .failure(let error):
				ALog.error("\(error.localizedDescription)")
			case .success(let carePlans):
				carePlan = carePlans.first as? OCKCarePlan
			}
			group.leave()
		}

		var tasks: [OCKTask] = []
		group.enter()
		store.fetchAnyTasks(query: OCKTaskQuery(for: Date()), callbackQueue: .main) { tasksResult in
			switch tasksResult {
			case .failure(let error):
				ALog.error("\(error.localizedDescription)")
			case .success(let newTasks):
				tasks = newTasks.compactMap { anyTask in
					anyTask as? OCKTask
				}.filter { task in
					task.hkLinkage != nil
				}
			}
			group.leave()
		}

		group.notify(queue: .main) { [weak self] in
			guard let carePlan = carePlan, !tasks.isEmpty else {
				self?.isSynchronizingOutcomes = false
				return
			}
			self?.synchronizeHealthKitOutcomes(carePlan: carePlan, tasks: tasks, completion: { _ in
				self?.isSynchronizingOutcomes = false
			})
		}
	}

	func synchronizeHealthKitOutcomes(carePlan: OCKCarePlan, tasks: [OCKTask], completion: @escaping ((Bool) -> Void)) {
		let now = Date()
		let lastUpdatedDate = UserDefaults.standard.lastObervationUploadDate
		guard lastUpdatedDate < now else {
			completion(true)
			return
		}

		var allSamples: [HKQuantityTypeIdentifier: [HKSample]] = [:]
		let group = DispatchGroup()
		for task in tasks {
			guard let linkage = task.hkLinkage?.hkLinkage else {
				continue
			}
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
			self?.uploadSamples(samples: allSamples, tasks: tasks, carePlanId: carePlan.id, completion: completion)
		}
	}

	func uploadSamples(samples: [HKQuantityTypeIdentifier: [HKSample]], tasks: [OCKTask], carePlanId: String, completion: @escaping ((Bool) -> Void)) {
		var outcomes: [Outcome] = []
		for task in tasks {
			guard let linkage = task.hkLinkage?.hkLinkage else {
				continue
			}
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
