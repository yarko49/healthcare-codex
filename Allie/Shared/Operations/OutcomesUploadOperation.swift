//
//  OutcomesUploadOperation.swift
//  Allie
//
//  Created by Waqar Malik on 5/16/21.
//

import CareKitStore
import Combine
import Foundation
import HealthKit

protocol OutcomesResultProvider {
	var outcomes: [CHOutcome]? { get }
}

enum OutcomeUploadError: Error {
	case missing(String)
	case query(String)
}

class OutcomesUploadOperation: AsynchronousOperation, OutcomesResultProvider {
	var outcomes: [CHOutcome]?
	var error: Error?
	var completionHandler: ((Result<[CHOutcome], Error>) -> Void)?
	var task: OCKHealthKitTask
	var chunkSize: Int
	@Injected(\.healthKitManager) var healthKitManager: HealthKitManager
	@Injected(\.networkAPI) var networkAPI: AllieAPI
	@Injected(\.careManager) var careManager: CareManager

	init(task: OCKHealthKitTask, chunkSize: Int, callbackQueue: DispatchQueue, completion: ((Result<[CHOutcome], Error>) -> Void)? = nil) {
		self.task = task
		self.chunkSize = chunkSize
		super.init()
		self.callbackQueue = callbackQueue
		self.completionHandler = completion
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
		let startDate = UserDefaults.standard[lastOutcomesUploadDate: linkage.quantityIdentifier.rawValue]
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
								UserDefaults.standard[lastOutcomesUploadDate: linkage.quantityIdentifier.rawValue] = endDate
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
								UserDefaults.standard[lastOutcomesUploadDate: linkage.quantityIdentifier.rawValue] = endDate
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
			careManager.outcome(sample: sample, deletedSample: nil, task: task, carePlanId: carePlanId)
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

	private func upload(outcomes: [CHOutcome], completion: @escaping AllieResultCompletion<[CHOutcome]>) {
		guard !outcomes.isEmpty else {
			completion(.success([]))
			return
		}
		let chunkedOutcomes = outcomes.chunked(into: chunkSize)
		let group = DispatchGroup()
		var errors: [Error] = []
		var uploaded: [CHOutcome] = []
		for chunkOutcome in chunkedOutcomes {
			group.enter()
			networkAPI.post(outcomes: chunkOutcome)
				.sink { completionResult in
					switch completionResult {
					case .failure(let error):
						errors.append(error)
						group.leave()
					case .finished:
						break
					}
				} receiveValue: { carePlanResponse in
					uploaded.append(contentsOf: carePlanResponse.outcomes)
					group.leave()
				}.store(in: &cancellables)
		}

		group.notify(queue: callbackQueue) {
			if !uploaded.isEmpty, errors.isEmpty {
				completion(.success(uploaded))
			} else {
				completion(.failure(AllieError.compound(errors)))
			}
		}
	}

	private func complete() {
		guard let handler = completionHandler else {
			finish()
			return
		}
		callbackQueue.async { [weak self] in
			if let results = self?.outcomes, self?.error == nil {
				handler(.success(results))
			} else if let error = self?.error {
				handler(.failure(error))
			} else {
				handler(.failure(URLError(.badServerResponse)))
			}
		}
		finish()
	}
}
