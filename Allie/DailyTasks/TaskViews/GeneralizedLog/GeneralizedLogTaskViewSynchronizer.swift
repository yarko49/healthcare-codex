//
//  GeneralizedLogTaskViewSynchronizer.swift
//  Allie
//
//  Created by Waqar Malik on 7/10/21.
//

import CareKit
import CareKitStore
import Foundation

class GeneralizedLogTaskViewSynchronizer: OCKTaskViewSynchronizerProtocol {
	typealias View = GeneralizedLogTaskView
	var task: OCKAnyTask?

	// Instantiate the custom view.
	func makeView() -> GeneralizedLogTaskView {
		GeneralizedLogTaskView()
	}

	func updateView(_ view: GeneralizedLogTaskView, context: OCKSynchronizationContext<OCKTaskEvents>) {
		view.updateWith(task: task, event: context.viewModel.first?.first, animated: context.animated)
	}
}
