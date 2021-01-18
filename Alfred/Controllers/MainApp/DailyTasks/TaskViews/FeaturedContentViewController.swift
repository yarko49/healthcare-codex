//
//  FeaturedContentViewController.swift
//  Alfred
//
//  Created by Waqar Malik on 1/16/21.
//

import CareKitStore
import CareKitUI
import SDWebImage
import UIKit

class FeaturedContentViewController: UIViewController, OCKFeaturedContentViewDelegate {
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

	func didTapView(_ view: OCKFeaturedContentView) {}

	private func configureView(task: OCKTask?) {
		featuredContentView.label.text = task?.title
		featuredContentView.label.textColor = .white
		let faturedURL = task?.featuredContentImageURL
		featuredContentView.imageView.sd_setImage(with: faturedURL, completed: nil)
	}
}
