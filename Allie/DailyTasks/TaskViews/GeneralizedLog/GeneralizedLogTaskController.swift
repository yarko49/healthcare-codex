//
//  GeneralizedLogTaskController.swift
//  Allie
//
//  Created by Waqar Malik on 7/10/21.
//

import CareKit
import CareKitStore
import Combine
import Foundation
import HealthKit

enum GeneralizedLogTaskControllerError: Error {
	case cannotMakeOutcomeFor(_ event: OCKAnyEvent)
}

class GeneralizedLogTaskController: OCKTaskController {
	@Injected(\.healthKitManager) var healthKitManager: HealthKitManager

	override func deleteOutcomeValue(at index: Int, for outcome: OCKAnyOutcome, completion: ((Result<OCKAnyOutcome, Error>) -> Void)?) {
		guard outcome.values.count > 1 else {
			super.deleteOutcomeValue(at: index, for: outcome, completion: completion)
			return
		}

		// Else delete the value from the outcome
		guard index < outcome.values.count else {
			ALog.error("Index out of bound \(index)")
			return
		}
		let outcomeValue = outcome.values[index]
		guard let uuid = outcomeValue.healthKitUUID, let identifier = outcomeValue.quantityIdentifier else {
			super.deleteOutcomeValue(at: index, for: outcome, completion: completion)
			return
		}

		healthKitManager.delete(uuid: uuid, quantityIdentifier: identifier) { result in
			switch result {
			case .failure(let error):
				completion?(.failure(error))
			case .success:
				var newOutcome = outcome
				newOutcome.values.remove(at: index)
				completion?(.success(newOutcome))
			}
		}
	}

	func deleteOutcome(value: OCKOutcomeValue, completion: AllieResultCompletion<HKSample>?) {
		guard let uuid = value.healthKitUUID, let identifier = value.quantityIdentifier else {
			completion?(.failure(AllieError.invalid("Invalid outcome value")))
			return
		}

		healthKitManager.delete(uuid: uuid, quantityIdentifier: identifier) { result in
			switch result {
			case .failure(let error):
				completion?(.failure(error))
			case .success(let sample):
				completion?(.success(sample))
			}
		}
	}
}
