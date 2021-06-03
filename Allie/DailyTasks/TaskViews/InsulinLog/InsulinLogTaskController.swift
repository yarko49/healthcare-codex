//
//  InsulinTaskLogController.swift
//  Allie
//
//  Created by Waqar Malik on 5/9/21.
//

import CareKit
import CareKitStore
import Combine
import Foundation

enum TaskControllerError: Error {
	case emptyTaskEvents
	case invalidIndexPath(IndexPath)
}

class InsulinLogTaskController: OCKTaskController {
	// This function gets called as a result of the delegate call in the view.
	override func setEvent(atIndexPath indexPath: IndexPath, isComplete: Bool, completion: ((Result<OCKAnyOutcome, Error>) -> Void)?) {
		super.setEvent(atIndexPath: indexPath, isComplete: isComplete, completion: completion)
		ALog.info("setEvent:atIndexPath:isComplete:completion:")
	}

	func append(outcomeValue: OCKOutcomeValue, at indexPath: IndexPath, completion: ((Result<OCKAnyOutcome, Error>) -> Void)?) {
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
			outcome.values.append(outcomeValue)
			storeManager.store.updateAnyOutcome(outcome, callbackQueue: .main) { result in
				completion?(result.mapError { $0 as Error })
			}

			// Else Save a new outcome if one does not exist
		} else {
			do {
				let outcome = try makeOutcomeFor(event: event, withValues: [outcomeValue])
				storeManager.store.addAnyOutcome(outcome, callbackQueue: .main) { result in
					completion?(result.mapError { $0 as Error })
				}
			} catch {
				completion?(.failure(error))
			}
		}
	}

	private func validatedViewModel() throws -> OCKTaskEvents {
		guard !taskEvents.isEmpty else {
			throw TaskControllerError.emptyTaskEvents
		}
		return taskEvents
	}

	private func validatedEvent(forIndexPath indexPath: IndexPath) throws -> OCKAnyEvent {
		guard let event = eventFor(indexPath: indexPath) else {
			throw TaskControllerError.invalidIndexPath(indexPath)
		}
		return event
	}
}
