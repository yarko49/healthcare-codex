//
//  ChecklistTaskViewSynchronizer.swift
//  Allie
//
//  Created by Waqar Malik on 5/23/21.
//

import CareKit
import CareKitUI
import Foundation

class ChecklistTaskViewSynchronizer: OCKChecklistTaskViewSynchronizer {
	override func makeView() -> OCKChecklistTaskView {
		let view = OCKChecklistTaskView(frame: .zero)
		view.headerView.detailDisclosureImage?.isHidden = true
		return view
	}

	override func updateView(_ view: OCKChecklistTaskView, context: OCKSynchronizationContext<OCKTaskEvents>) {
		// Apply a custom sort to the events before they are displayed in the view
		let sortedEvents = context.viewModel.flatMap { events in
			events.sorted { lhs, rhs in
				lhs.scheduleEvent.element.start < rhs.scheduleEvent.element.start
			}
		}
		let newTaskEvents = OCKTaskEvents(events: sortedEvents)
		let newContext = OCKSynchronizationContext(viewModel: newTaskEvents, oldViewModel: context.oldViewModel, animated: context.animated)
		super.updateView(view, context: newContext)
	}
}
