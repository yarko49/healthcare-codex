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
		view.updateWith(event: context.viewModel.first?.first, animated: context.animated)
	}
}
