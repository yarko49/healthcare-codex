//
//  GridTaskViewSynchronizer.swift
//  Allie
//
//  Created by Waqar Malik on 5/23/21.
//

import CareKit
import CareKitStore
import CareKitUI
import Foundation

class GridTaskViewSynchronizer: OCKGridTaskViewSynchronizer {
	override open func makeView() -> OCKGridTaskView {
		let view = OCKGridTaskView(frame: .zero)
		view.headerView.detailDisclosureImage?.isHidden = true
		return view
	}

	override func updateView(_ view: OCKGridTaskView, context: OCKSynchronizationContext<OCKTaskEvents>) {
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
