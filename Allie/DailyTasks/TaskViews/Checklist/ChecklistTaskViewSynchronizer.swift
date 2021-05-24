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
}
