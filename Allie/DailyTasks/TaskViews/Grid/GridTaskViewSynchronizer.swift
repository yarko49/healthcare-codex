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
}
