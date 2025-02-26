//
//  HealthKitOutcomesUploadOperation.swift
//  Allie
//
//  Created by Waqar Malik on 5/16/21.
//

import CareKitStore
import Combine
import Foundation
import HealthKit

class HealthKitOutcomesUploadOperation: OutcomesUploadOperation {
	var task: OCKHealthKitTask
	@Injected(\.healthKitManager) var healthKitManager: HealthKitManager

	init(task: OCKHealthKitTask, chunkSize: Int, callbackQueue: DispatchQueue, completion: ((Result<[CHOutcome], Error>) -> Void)? = nil) {
		self.task = task
		super.init(chunkSize: chunkSize, callbackQueue: callbackQueue, completion: completion)
	}

	private func queryHealthKit(quantityType: HKQuantityType, completion: AllieResultCompletion<[HKSample]>) {}

	override func main() {
		guard let carePlanId = task.carePlanId, !isCancelled else {
			error = OutcomeUploadError.missing("Missing CarePlan Id for TaskId = \(task.id)")
			complete()
			return
		}

		let linkage = task.healthKitLinkage
		guard let quantityType = HKObjectType.quantityType(forIdentifier: linkage.quantityIdentifier), !isCancelled else {
			error = OutcomeUploadError.missing("Missing QuantityType for identifier \(linkage.quantityIdentifier.rawValue)")
			complete()
			return
		}
		let startDate = UserDefaults.standard[healthKitOutcomesUploadDate: linkage.quantityIdentifier.rawValue]
		let endDate = Date()
		if linkage.quantityIdentifier == .bloodPressureSystolic || linkage.quantityIdentifier == .bloodPressureDiastolic {
			healthKitManager.bloodPressure(startDate: startDate, endDate: endDate, options: []) { [weak self] queryResult in
				guard let strongSelf = self else {
					self?.complete()
					return
				}
				switch queryResult {
				case .failure(let error):
					strongSelf.error = error
					strongSelf.complete()
					return
				case .success(let samples):
					ALog.trace("\(samples.count) found for identifier \(linkage.quantityIdentifier.rawValue), startDate \(startDate) endDate \(endDate)")
					strongSelf.upload(samples: samples, carePlanId: carePlanId) { uploadResult in
						switch uploadResult {
						case .failure(let error):
							strongSelf.error = error
						case .success(let outcomes):
							self?.outcomes = outcomes
							if !outcomes.isEmpty {
								UserDefaults.standard[healthKitOutcomesUploadDate: linkage.quantityIdentifier.rawValue] = endDate
							}
						}
						strongSelf.complete()
					}
				}
			}
		} else {
			healthKitManager.samples(for: quantityType, startDate: startDate, endDate: endDate, options: []) { [weak self] queryResult in
				guard let strongSelf = self else {
					self?.complete()
					return
				}
				switch queryResult {
				case .failure(let error):
					strongSelf.error = error
					strongSelf.complete()
					return
				case .success(let samples):
					ALog.trace("\(samples.count) found for identifier \(linkage.quantityIdentifier.rawValue), startDate \(startDate) endDate \(endDate)")
					strongSelf.upload(samples: samples, carePlanId: carePlanId) { uploadResult in
						switch uploadResult {
						case .failure(let error):
							strongSelf.error = error
						case .success(let outcomes):
							self?.outcomes = outcomes
							if !outcomes.isEmpty {
								UserDefaults.standard[healthKitOutcomesUploadDate: linkage.quantityIdentifier.rawValue] = endDate
							}
						}
						strongSelf.complete()
					}
				}
			}
		}
	}

	private func upload(samples: [HKSample], carePlanId: String, completion: @escaping AllieResultCompletion<[CHOutcome]>) {
		guard !samples.isEmpty else {
			completion(.success([]))
			return
		}

		let taskOucomes: [CHOutcome] = samples.compactMap { sample in
			careManager.fetchOutcome(sample: sample, deletedSample: nil, task: task, carePlanId: carePlanId)
		}

		guard taskOucomes.count == samples.count else {
			completion(.failure(OutcomeUploadError.missing("Unable to convert all items to outcomes \(task.healthKitLinkage.quantityIdentifier.rawValue)")))
			return
		}

		upload(outcomes: taskOucomes, completion: completion)
	}

	private func upload(statistics: [HKStatistics], carePlanId: String, completion: @escaping AllieResultCompletion<[CHOutcome]>) {
		guard !statistics.isEmpty else {
			completion(.success([]))
			return
		}

		let taskOucomes: [CHOutcome] = statistics.compactMap { value in
			CHOutcome(statistics: value, task: task, carePlanId: carePlanId)
		}

		guard taskOucomes.count == statistics.count else {
			completion(.failure(OutcomeUploadError.missing("Unable to convert all items to outcomes \(task.healthKitLinkage.quantityIdentifier.rawValue)")))
			return
		}

		upload(outcomes: taskOucomes, completion: completion)
	}
}
