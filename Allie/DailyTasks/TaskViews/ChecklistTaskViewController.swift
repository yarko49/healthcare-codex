//
//  ChecklistTaskViewController.swift
//  Allie
//
//  Created by Waqar Malik on 1/17/21.
//

import CareKit
import CareKitUI
import UIKit

class ChecklistTaskViewController: OCKChecklistTaskViewController {
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		AnalyticsManager.send(event: .pageView, properties: [.name: "CheckListTaskView"])
	}

	override open func didSelectTaskView(_ taskView: UIView & OCKTaskDisplayable, eventIndexPath: IndexPath) {}
}
