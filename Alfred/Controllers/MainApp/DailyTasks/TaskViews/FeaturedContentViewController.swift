//
//  FeaturedContentViewController.swift
//  Alfred
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

	private func configureView(task: OCKTask?) {
		self.task = task
		featuredContentView.label.text = task?.title
		featuredContentView.label.textColor = .white
		let faturedURL = task?.featuredContentImageURL
		featuredContentView.imageView.sd_setImage(with: faturedURL, completed: nil)
	}

	func didTapView(_ view: OCKFeaturedContentView) {
		let detailViewText = task?.userInfo?["detailView"] ?? ""
		let imageTitle = task?.userInfo?["detailViewImageLabel"] ?? featuredContentView.label.text
		let detailViewController = OCKDetailViewController(html: .init(html: detailViewText, css: nil), imageOverlayStyle: .unspecified, showsCloseButton: true)
		detailViewController.detailView.imageView.image = featuredContentView.imageView.image
		detailViewController.detailView.imageLabel.text = imageTitle
		detailViewController.detailView.imageLabel.textColor = .white
		present(detailViewController, animated: true)
	}
}
