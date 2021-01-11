//
//  CarePlanTasksViewController.swift
//  Alfred
//
//  Created by Waqar Malik on 1/7/21.
//

import CareKit
import UIKit

class CarePlanTasksViewController: OCKDailyTasksPageViewController {
	var carePlanStoreManager: CarePlanStoreManager {
		AppDelegate.appDelegate.carePlanStoreManager
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		title = NSLocalizedString("TASKS", comment: "Tasks")

		carePlanStoreManager.populateStore { [weak self] success in
			ALog.info("polulate store = \(success)")
			DispatchQueue.main.async {
				self?.reload()
			}
		}
	}
}
