//
//  GridTaskViewController.swift
//  Allie
//
//  Created by Waqar Malik on 1/16/21.
//

import CareKit
import CareKitUI
import UIKit

class GridTaskViewController: OCKGridTaskViewController {
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		AnalyticsManager.send(event: .pageView, properties: [.name: "GridTaskView"])
	}

	override open func didSelectTaskView(_ taskView: UIView & OCKTaskDisplayable, eventIndexPath: IndexPath) {}
}
