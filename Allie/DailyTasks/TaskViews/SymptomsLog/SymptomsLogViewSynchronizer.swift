//
//  SymptomsLogViewSynchronizer.swift
//  Allie
//
//  Created by Waqar Malik on 10/26/21.
//

import CareKit
import CareKitStore
import Foundation

class SymptomsLogViewSynchronizer: OCKTaskViewSynchronizerProtocol {
	typealias View = SymptomsLogView
	var task: OCKAnyTask?

	// Instantiate the custom view.
	func makeView() -> SymptomsLogView {
		SymptomsLogView()
	}

	func updateView(_ view: SymptomsLogView, context: OCKSynchronizationContext<OCKTaskEvents>) {
		view.updateWith(task: task, event: context.viewModel.first?.first, animated: context.animated)
	}
}
