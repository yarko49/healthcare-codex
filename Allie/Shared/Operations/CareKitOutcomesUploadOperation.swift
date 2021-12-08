//
//  CareKitOutcomesUploadOperation.swift
//  Allie
//
//  Created by Waqar Malik on 11/29/21.
//

import CareKitStore
import Foundation

class CareKitOutcomesUploadOperation: OutcomesUploadOperation {
	var task: OCKTask

	init(task: OCKTask, chunkSize: Int, callbackQueue: DispatchQueue, completion: ((Result<[CHOutcome], Error>) -> Void)? = nil) {
		self.task = task
		super.init(chunkSize: chunkSize, callbackQueue: callbackQueue, completion: completion)
	}

	override func main() {
		guard let carePlanId = task.carePlanId, !isCancelled else {
			error = OutcomeUploadError.missing("Missing CarePlan Id for TaskId = \(task.id)")
			complete()
			return
		}

		let identifier = task.id
		let startDate = UserDefaults.standard[outcomesUploadDate: identifier]
		let endDate = Date()
		careManager.fetchOutcomes(taskId: task.uuid, startDate: startDate, endDate: endDate, callbackQueue: callbackQueue) { [weak self] queryResult in
			guard let strongSelf = self else {
				self?.complete()
				return
			}
			switch queryResult {
			case .failure(let error):
				strongSelf.error = error
				strongSelf.complete()
				return
			case .success(let ockOutomes):
				let outcomes = ockOutomes.compactMap { outcome in
					CHOutcome(outcome: outcome, carePlanID: carePlanId, task: strongSelf.task)
				}
				strongSelf.upload(outcomes: outcomes) { uploadResult in
					switch uploadResult {
					case .failure(let error):
						strongSelf.error = error
					case .success(let outcomes):
						self?.outcomes = outcomes
						if !outcomes.isEmpty {
							UserDefaults.standard[outcomesUploadDate: identifier] = endDate
						}
					}
					strongSelf.complete()
				}
			}
		}
	}
}
