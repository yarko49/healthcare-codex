//
//  CareManager+Tasks.swift
//  Allie
//
//  Created by Waqar Malik on 9/11/21.
//

import CareKitStore
import Foundation

extension CareManager {
	func synchronizeOutcomes(carePlanId: String, tasks: [String], completion: @escaping AllieResultCompletion<Bool>) {
		guard !tasks.isEmpty else {
			completion(.success(false))
			return
		}
		var errors: [Error] = []
		let group = DispatchGroup()
		for task in tasks {
			group.enter()
			synchronizeOutcomes(carePlanId: carePlanId, taskId: task) { downloadResult in
				if case .failure(let error) = downloadResult {
					errors.append(error)
					ALog.error("Unable to synchronize outcomes for task \(task), carePlan = \(carePlanId)", error: error)
				}
				group.leave()
			}
		}

		group.notify(queue: .main) {
			completion(errors.isEmpty ? .success(true) : .failure(AllieError.compound(errors)))
		}
	}
}
