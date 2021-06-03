//
//  ButtonLogTaskViewSynchronizer.swift
//  Allie
//
//  Created by Waqar Malik on 5/23/21.
//

import CareKit
import CareKitStore
import CareKitUI
import Foundation

class ButtonLogTaskViewSynchronizer: OCKButtonLogTaskViewSynchronizer {
	override open func makeView() -> OCKButtonLogTaskView {
		let view = OCKButtonLogTaskView(frame: .zero)
		view.headerView.detailDisclosureImage?.isHidden = true
		return view
	}
}
