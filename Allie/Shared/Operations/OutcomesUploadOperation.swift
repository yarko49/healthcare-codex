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
	var outcomes: [Outcome]? { get }
}

enum OutcomeUploadError: Error {
	case missing(String)
	case query(String)
}

class OutcomesUploadOperation: AsynchronousOperation, OutcomesResultProvider {
	var outcomes: [Outcome]?
	var error: Error?
	var completionHandler: ((Result<[Outcome], Error>) -> Void)?
	var task: OCKHealthKitTask
	var chunkSize: Int
	init(task: OCKHealthKitTask, chunkSize: Int, callbackQueue: DispatchQueue, completion: ((Result<[Outcome], Error>) -> Void)? = nil) {
		self.task = task
		self.chunkSize = chunkSize
		super.init()
		self.callbackQueue = callbackQueue
		self.completionHandler = completion
	}

	override func main() {
		guard let carePlanId = task.carePlanId else {
			error = OutcomeUploadError.missing("Missing CarePlan Id for TaskId = \(task.id)")
			complete()
			return
		}

		let linkage = task.healthKitLinkage
		let startDate = UserDefaults.standard[lastOutcomesUploadDate: linkage.quantityIdentifier.rawValue]
		let endDate = Date()
		if let quantityType = HKObjectType.quantityType(forIdentifier: linkage.quantityIdentifier) {
			HealthKitManager.shared.queryHealthData(quantityType: quantityType, startDate: startDate, endDate: endDate, options: []) { [weak self] success, samples in
				guard let strongSelf = self else {
					self?.complete()
					return
				}

				guard success else {
					self?.error = OutcomeUploadError.query("HealthKit Error for quantityType \(linkage.quantityIdentifier.rawValue)")
					self?.complete()
					return
				}

				guard !samples.isEmpty else {
					self?.outcomes = []
					self?.complete()
					return
				}

				ALog.info("\(samples.count) found for identifier \(linkage.quantityIdentifier.rawValue), startDate \(startDate) endDate \(endDate)")
				let taskOucomes: [Outcome] = samples.compactMap { sample in
					Outcome(sample: sample, task: strongSelf.task, carePlanId: carePlanId)
				}

				guard taskOucomes.count == samples.count else {
					self?.error = OutcomeUploadError.missing("Unable to convert all items to outcomes \(linkage.quantityIdentifier.rawValue)")
					self?.complete()
					return
				}

				let chunkedOutcomes = taskOucomes.chunked(into: strongSelf.chunkSize)
				let group = DispatchGroup()
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
						} receiveValue: { [weak self] carePlanResponse in
							if self?.outcomes == nil {
								self?.outcomes = []
							}
							self?.outcomes?.append(contentsOf: carePlanResponse.outcomes)
							group.leave()
						}.store(in: &strongSelf.cancellables)
				}

				group.notify(queue: strongSelf.callbackQueue) {
					if let values = self?.outcomes, self?.error == nil {
						if !values.isEmpty {
							UserDefaults.standard[lastOutcomesUploadDate: linkage.quantityIdentifier.rawValue] = endDate
						}
					}
					strongSelf.complete()
				}
			}
		} else {
			error = OutcomeUploadError.missing("Missing QuantityType for identifier \(linkage.quantityIdentifier.rawValue)")
			complete()
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
