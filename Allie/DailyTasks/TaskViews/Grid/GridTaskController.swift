//
//  GridTaskController.swift
//  Allie
//
//  Created by Waqar Malik on 6/8/21.
//

import CareKit
import CareKitStore
import Foundation

class GridTaskController: OCKGridTaskController {
	override func eventFor(indexPath: IndexPath) -> OCKAnyEvent? {
		// Apply a custom sort to the events before modifying data in the store
		// This ensures we modify the correct event in the store.
		let sortedEvents = taskEvents.flatMap { events in
			events.sorted { lhs, rhs in
				lhs.scheduleEvent.element.start < rhs.scheduleEvent.element.start
			}
		}
		let newTaskEvents = OCKTaskEvents(events: sortedEvents)
		return newTaskEvents[indexPath.section][indexPath.row]
	}
}
