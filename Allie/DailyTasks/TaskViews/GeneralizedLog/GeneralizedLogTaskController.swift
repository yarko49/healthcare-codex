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

	func deleteOutcomeValuesByRecord(at index: Int, for outcome: OCKAnyOutcome, completion: ((Result<OCKAnyOutcome, Error>) -> Void)?) {
		guard outcome.values.count > 1 else {
			super.deleteOutcomeValue(at: 0, for: outcome, completion: completion)
			return
		}

		let valuesCountForRecord = outcome.valuesCountPerRecord
		let startIndex = index * valuesCountForRecord
		let endIndex = (index + 1) * valuesCountForRecord - 1

		guard endIndex < outcome.values.count else {
			ALog.error("Index out of bound \(index)")
			return
		}

		if let uuid = outcome.values[startIndex].healthKitUUID, let identifier = outcome.values[startIndex].quantityIdentifier {
			// Delete sample itself, so we don't need to iterate all the values
			healthKitManager.delete(uuid: uuid, quantityIdentifier: identifier) { result in
				switch result {
				case .failure(let error):
					completion?(.failure(error))
				case .success:
					var newOutcome = outcome

					// Reverse iteration, since we are removing
					for index in stride(from: endIndex, through: startIndex, by: -1) {
						newOutcome.values.remove(at: index)
					}
					completion?(.success(newOutcome))
				}
			}
		} else {
			var newOutcome = outcome

			// Reverse iteration, since we are removing
			for index in stride(from: endIndex, through: startIndex, by: -1) {
				newOutcome.values.remove(at: index)
			}
			storeManager.store.updateAnyOutcome(newOutcome, callbackQueue: .main) { result in
				completion?(result.mapError { $0 as Error })
			}
		}
	}

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

		if identifier == HKQuantityTypeIdentifier.bloodPressureSystolic.rawValue || identifier == HKQuantityTypeIdentifier.bloodPressureDiastolic.rawValue {
			guard let bloodPressureType = HKCorrelationType.correlationType(forIdentifier: .bloodPressure) else {
				completion?(.failure(HealthKitManagerError.invalidInput("Invalid quantityIdentifier")))
				return
			}
			healthKitManager.deleteCorrelationSample(uuid: uuid, sampleType: bloodPressureType, completion: completion)
		} else {
			healthKitManager.delete(uuid: uuid, quantityIdentifier: identifier, completion: completion)
		}
	}
}
