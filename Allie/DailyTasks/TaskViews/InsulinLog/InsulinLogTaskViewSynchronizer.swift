//
//  InsulinLogTaskViewSynchronizer.swift
//  Allie
//
//  Created by Waqar Malik on 5/9/21.
//

import CareKit
import CareKitStore
import Foundation

class InsulinLogTaskViewSynchronizer: OCKTaskViewSynchronizerProtocol {
	typealias View = InsulinLogTaskView
	var healthKitTask: OCKHealthKitTask?

	// Instantiate the custom view.
	func makeView() -> InsulinLogTaskView {
		InsulinLogTaskView()
	}

	func updateView(_ view: InsulinLogTaskView, context: OCKSynchronizationContext<OCKTaskEvents>) {
		let events = context.viewModel
		let task = events.first?.first?.task ?? healthKitTask
		view.headerView.titleLabel.text = task?.title ?? "Insulin"
		view.headerView.detailLabel.text = "Anytime"
		view.instructionsLabel.text = task?.instructions ?? "Monitor daily insulin levels"
	}
}
