//
//  NumericProgressViewController.swift
//  Allie
//
//  Created by Waqar Malik on 10/6/21.
//

import CareKit
import CareKitStore
import CareKitUI
import SwiftUI
import UIKit

class NumericProgressViewController: UIViewController {
	let viewController: UIViewController?

	init(task: OCKAnyTask, eventQuery: OCKEventQuery, storeManager: OCKSynchronizedStoreManager) {
		let view = NumericProgressTaskView(task: task, eventQuery: eventQuery, storeManager: storeManager)
		self.viewController = UIHostingController(rootView: view)
		viewController?.view.backgroundColor = .clear
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func loadView() {
		super.loadView()
		if let viewController = viewController {
			viewController.additionalSafeAreaInsets = UIEdgeInsets(top: 1.0, left: 0.0, bottom: 0.0, right: 1.0)
			addChild(viewController)
			view.addSubview(viewController.view)
			viewController.didMove(toParent: self)
		}
	}

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		viewController?.view.frame = view.bounds
	}
}
