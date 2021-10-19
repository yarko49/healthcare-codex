//
//  SimpleTaskViewSynchronizer.swift
//  Allie
//
//  Created by Waqar Malik on 10/18/21.
//

import CareKit
import CareKitStore
import CareKitUI
import Foundation

class SimpleTaskViewSynchronizer: OCKTaskViewSynchronizerProtocol {
	var task: OCKAnyTask?

	func makeView() -> SimpleTaskView {
		.init()
	}

	func updateView(_ view: SimpleTaskView, context: OCKSynchronizationContext<OCKTaskEvents>) {
		view.updateWith(task: task, event: context.viewModel.first?.first, animated: context.animated)
	}
}
