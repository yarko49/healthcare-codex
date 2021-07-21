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

class GeneralizedLogTaskController: OCKTaskController {
	func validatedViewModel() throws -> OCKTaskEvents {
		guard !taskEvents.isEmpty else {
			throw AllieError.missing("Empty Task Events")
		}
		return taskEvents
	}

	func validatedEvent(forIndexPath indexPath: IndexPath) throws -> OCKAnyEvent {
		guard let event = eventFor(indexPath: indexPath) else {
			throw AllieError.invalid("Invalid Index Path")
		}
		return event
	}
}
