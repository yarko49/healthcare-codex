//
//  ButtonLogTaskViewController.swift
//  Allie
//
//  Created by Waqar Malik on 1/16/21.
//

import CareKit
import CareKitStore
import CareKitUI
import UIKit

class ButtonLogTaskViewController: OCKTaskViewController<OCKButtonLogTaskController, ButtonLogTaskViewSynchronizer> {
	var task: OCKTask?
	var eventQuery = OCKEventQuery(for: Date())

	override public init(controller: OCKButtonLogTaskController, viewSynchronizer: ButtonLogTaskViewSynchronizer) {
		super.init(controller: controller, viewSynchronizer: viewSynchronizer)
	}

	override public init(viewSynchronizer: ButtonLogTaskViewSynchronizer, task: OCKAnyTask, eventQuery: OCKEventQuery, storeManager: OCKSynchronizedStoreManager) {
		self.task = task as? OCKTask
		self.eventQuery = eventQuery
		super.init(viewSynchronizer: viewSynchronizer, task: task, eventQuery: eventQuery, storeManager: storeManager)
	}

	override public init(viewSynchronizer: ButtonLogTaskViewSynchronizer, taskID: String, eventQuery: OCKEventQuery, storeManager: OCKSynchronizedStoreManager) {
		self.eventQuery = eventQuery
		super.init(viewSynchronizer: viewSynchronizer, taskID: taskID, eventQuery: eventQuery, storeManager: storeManager)
	}

	public init(task: OCKAnyTask, eventQuery: OCKEventQuery, storeManager: OCKSynchronizedStoreManager) {
		self.task = task as? OCKTask
		self.eventQuery = eventQuery
		super.init(viewSynchronizer: .init(), task: task, eventQuery: eventQuery, storeManager: storeManager)
	}

	public init(taskID: String, eventQuery: OCKEventQuery, storeManager: OCKSynchronizedStoreManager) {
		self.eventQuery = eventQuery
		super.init(viewSynchronizer: .init(), taskID: taskID, eventQuery: eventQuery, storeManager: storeManager)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		AnalyticsManager.send(event: .pageView, properties: [.name: "ButtonLogTaskView"])
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
