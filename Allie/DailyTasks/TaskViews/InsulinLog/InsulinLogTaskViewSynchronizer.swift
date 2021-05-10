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

	// Instantiate the custom view.
	func makeView() -> InsulinLogTaskView {
		InsulinLogTaskView()
	}

	func updateView(_ view: InsulinLogTaskView, context: OCKSynchronizationContext<OCKTaskEvents>) {
		let event = context.viewModel.first?.first
		view.headerView.titleLabel.text = event?.task.title ?? "Insulin"
		view.headerView.detailLabel.text = event?.task.schedule.startDate().description ?? "Anytime today"
		//        view.titleLabel?.text = event?.task.title
		//        view.isSelected = event?.outcome != nil
	}
}
