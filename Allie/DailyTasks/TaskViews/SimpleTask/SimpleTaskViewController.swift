//
//  SimpleTaskViewController.swift
//  Allie
//
//  Created by Waqar Malik on 2/24/21.
//

import CareKit
import CareKitStore
import CareKitUI
import UIKit

class SimpleTaskViewController: OCKTaskViewController<SimpleTaskController, SimpleTaskViewSynchronizer> {
	var task: OCKTask?
	var eventQuery = OCKEventQuery(for: Date())

	override init(controller: SimpleTaskController, viewSynchronizer: SimpleTaskViewSynchronizer) {
		super.init(controller: controller, viewSynchronizer: viewSynchronizer)
	}

	override init(viewSynchronizer: SimpleTaskViewSynchronizer, task: OCKAnyTask, eventQuery: OCKEventQuery, storeManager: OCKSynchronizedStoreManager) {
		self.eventQuery = eventQuery
		super.init(viewSynchronizer: viewSynchronizer, task: task, eventQuery: eventQuery, storeManager: storeManager)
	}

	override init(viewSynchronizer: SimpleTaskViewSynchronizer, taskID: String, eventQuery: OCKEventQuery, storeManager: OCKSynchronizedStoreManager) {
		self.eventQuery = eventQuery
		super.init(viewSynchronizer: viewSynchronizer, taskID: taskID, eventQuery: eventQuery, storeManager: storeManager)
	}

	init(task: OCKAnyTask, eventQuery: OCKEventQuery, storeManager: OCKSynchronizedStoreManager) {
		self.task = task as? OCKTask
		let synchronizer = SimpleTaskViewSynchronizer()
		synchronizer.task = task
		self.eventQuery = eventQuery
		super.init(viewSynchronizer: synchronizer, task: task, eventQuery: eventQuery, storeManager: storeManager)
	}

	init(taskID: String, eventQuery: OCKEventQuery, storeManager: OCKSynchronizedStoreManager) {
		self.eventQuery = eventQuery
		super.init(viewSynchronizer: .init(), taskID: taskID, eventQuery: eventQuery, storeManager: storeManager)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		AnalyticsManager.send(event: .pageView, properties: [.name: "SimpleTaskView"])
	}

	override open func didSelectTaskView(_ taskView: UIView & OCKTaskDisplayable, eventIndexPath: IndexPath) {
		if let html = task?.featuredContentDetailViewHTML {
			let css = task?.featuredContentDetailViewCSS
			let imageURL = task?.featuredContentImageURL
			let title = task?.featuredContentDetailViewImageLabel
			showHTMLCSSContent(title: title, html: html, css: css, image: nil, imageURL: imageURL)
		} else if let text = task?.featuredContentDetailViewText {
			let title = task?.featuredContentDetailViewImageLabel
			let imageURL = task?.featuredContentImageURL
			showTextContent(title: title, content: text, image: nil, imageURL: imageURL)
		} else if let url = task?.featuredContentDetailViewURL {
			showURLContent(url: url)
		}
	}
}
