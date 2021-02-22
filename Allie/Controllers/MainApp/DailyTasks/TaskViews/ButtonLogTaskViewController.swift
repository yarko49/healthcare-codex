//
//  ButtonLogTaskViewController.swift
//  Allie
//
//  Created by Waqar Malik on 1/16/21.
//

import CareKit
import CareKitUI
import UIKit

class ButtonLogTaskViewController: OCKButtonLogTaskViewController {
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		AnalyticsManager.send(event: .pageView, properties: [.name: "ButtonLogTaskView"])
	}

	override open func didSelectTaskView(_ taskView: UIView & OCKTaskDisplayable, eventIndexPath: IndexPath) {}
}
