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

class ButtonLogTaskViewController: OCKButtonLogTaskViewController {
	var task: OCKTask?

	override public init(task: OCKAnyTask, eventQuery: OCKEventQuery, storeManager: OCKSynchronizedStoreManager) {
		self.task = task as? OCKTask
		super.init(task: task, eventQuery: eventQuery, storeManager: storeManager)
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
			showHTMLCSSContent(title: title, html: html, css: css, imageURL: imageURL)
		} else if let text = task?.featuredContentDetailViewText {
			let title = task?.featuredContentDetailViewImageLabel
			let imageURL = task?.featuredContentImageURL
			showTextContent(title: title, content: text, imageURL: imageURL)
		} else if let url = task?.featuredContentDetailViewURL {
			showURLContent(url: url)
		}
	}
}
