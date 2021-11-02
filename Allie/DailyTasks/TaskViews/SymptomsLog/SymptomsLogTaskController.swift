//
//  SymptomsLogTaskController.swift
//  Allie
//
//  Created by Waqar Malik on 10/26/21.
//

import CareKit
import CareKitStore
import Foundation

class SymptomsLogTaskController: OCKTaskController {
	func append(value: OCKOutcomeValue, at indexPath: IndexPath, completion: ((Result<OCKAnyOutcome, Error>) -> Void)?) {
		let event: OCKAnyEvent
		do {
			_ = try validatedViewModel()
			event = try validatedEvent(forIndexPath: indexPath)
		} catch {
			completion?(.failure(error))
			return
		}

		// Update the outcome with the new value
		if var outcome = event.outcome {
			outcome.values.append(value)
			storeManager.store.updateAnyOutcome(outcome, callbackQueue: .main) { result in
				completion?(result.mapError { $0 as Error })
			}

			// Else Save a new outcome if one does not exist
		} else {
			do {
				let outcome = try makeOutcomeFor(event: event, withValues: [value])
				storeManager.store.addAnyOutcome(outcome, callbackQueue: .main) { result in
					completion?(result.mapError { $0 as Error })
				}
			} catch {
				completion?(.failure(error))
			}
		}
	}

	func update(value: OCKOutcomeValue, at indexPath: IndexPath, index: Int, completion: ((Result<OCKAnyOutcome, Error>) -> Void)?) {
		let event: OCKAnyEvent
		do {
			_ = try validatedViewModel()
			event = try validatedEvent(forIndexPath: indexPath)
		} catch {
			completion?(.failure(error))
			return
		}

		// Update the outcome with the new value
		if var outcome = event.outcome {
			if index < outcome.values.count {
				outcome.values[index] = value
			} else {
				outcome.values.append(value)
			}
			storeManager.store.updateAnyOutcome(outcome, callbackQueue: .main) { result in
				completion?(result.mapError { $0 as Error })
			}

			// Else Save a new outcome if one does not exist
		} else {
			do {
				let outcome = try makeOutcomeFor(event: event, withValues: [value])
				storeManager.store.addAnyOutcome(outcome, callbackQueue: .main) { result in
					completion?(result.mapError { $0 as Error })
				}
			} catch {
				completion?(.failure(error))
			}
		}
	}
}
