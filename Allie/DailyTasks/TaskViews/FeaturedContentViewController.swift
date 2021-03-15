//
//  FeaturedContentViewController.swift
//  Allie
//
//  Created by Waqar Malik on 1/16/21.
//

import CareKit
import CareKitStore
import CareKitUI
import SDWebImage
import UIKit

class FeaturedContentViewController: UIViewController, OCKFeaturedContentViewDelegate {
	var task: OCKTask?

	private let imageOverlayStyle: UIUserInterfaceStyle

	lazy var featuredContentView: OCKFeaturedContentView = {
		let view = OCKFeaturedContentView(imageOverlayStyle: imageOverlayStyle)
		view.delegate = self
		return view
	}()

	init(task: OCKAnyTask, imageOverlayStyle: UIUserInterfaceStyle = .unspecified) {
		self.imageOverlayStyle = imageOverlayStyle
		super.init(nibName: nil, bundle: nil)
		configureView(task: task as? OCKTask)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	@available(*, unavailable)
	override func loadView() {
		view = featuredContentView
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		AnalyticsManager.send(event: .pageView, properties: [.name: "FeaturedContentView"])
	}

	private func configureView(task: OCKTask?) {
		self.task = task
		featuredContentView.label.text = task?.title
		featuredContentView.label.textColor = .white
		let faturedURL = task?.featuredContentImageURL
		featuredContentView.imageView.sd_setImage(with: faturedURL, completed: nil)
	}

	func didTapView(_ view: OCKFeaturedContentView) {
		if let html = task?.featuredContentDetailViewHTML {
			let css = task?.featuredContentDetailViewCSS
			let imageURL = task?.featuredContentImageURL
			let title = task?.featuredContentDetailViewImageLabel ?? featuredContentView.label.text
			showHTMLCSSContent(title: title, html: html, css: css, imageURL: imageURL)
		} else if let text = task?.featuredContentDetailViewText {
			let imageURL = task?.featuredContentImageURL
			let title = task?.featuredContentDetailViewImageLabel
			showTextContent(title: title, content: text, imageURL: imageURL)
		} else if let url = task?.featuredContentDetailViewURL {
			showURLContent(url: url)
		}
	}
}
