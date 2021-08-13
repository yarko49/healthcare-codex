//
//  FeaturedContentViewController.swift
//  Allie
//
//  Created by Waqar Malik on 1/16/21.
//

import CareKit
import CareKitStore
import CareKitUI
import JGProgressHUD
import SDWebImage
import UIKit

class FeaturedContentViewController: UIViewController, OCKFeaturedContentViewDelegate {
	var task: OCKTask?
	lazy var hud: JGProgressHUD = {
		let view = JGProgressHUD()
		view.largeContentTitle = NSLocalizedString("LOADING", comment: "Loading")
		return view
	}()

	private let imageOverlayStyle: UIUserInterfaceStyle

	lazy var featuredContentView: OCKFeaturedContentView = {
		let view = OCKFeaturedContentView(imageOverlayStyle: imageOverlayStyle)
		view.imageView.contentMode = .scaleAspectFill
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
		if let task = task, let asset = task.asset, !asset.isEmpty {
			CareManager.shared.image(task: task) { [weak self] result in
				switch result {
				case .failure(let error):
					ALog.error("unable to download image", error: error)
				case .success(let image):
					DispatchQueue.main.async {
						self?.featuredContentView.imageView.image = image
					}
				}
			}
		} else {
			let faturedURL = task?.featuredContentImageURL
			featuredContentView.imageView.sd_setImage(with: faturedURL, completed: nil)
		}
	}

	func didTapView(_ view: OCKFeaturedContentView) {
		if let html = task?.featuredContentDetailViewHTML, !html.isEmpty {
			let css = task?.featuredContentDetailViewCSS
			let title = task?.featuredContentDetailViewImageLabel ?? task?.title
			let imageURL = task?.featuredContentImageURL
			showHTMLCSSContent(title: title, html: html, css: css, image: view.imageView.image, imageURL: imageURL)
		} else if let text = task?.featuredContentDetailViewText, !text.isEmpty {
			let imageURL = task?.featuredContentImageURL
			let title = task?.featuredContentDetailViewImageLabel
			showTextContent(title: title, content: text, image: view.imageView.image, imageURL: imageURL)
		} else if let url = task?.featuredContentDetailViewURL {
			showURLContent(url: url)
		} else if let task = task, let asset = task.featuredContentDetailViewAsset, asset.hasSuffix("pdf") {
			hud.show(in: tabBarController?.view ?? navigationController?.view ?? view, animated: true)
			CareManager.shared.pdfData(task: task) { [weak self] result in
				DispatchQueue.main.async {
					self?.hud.dismiss(animated: true)
				}
				switch result {
				case .failure(let error):
					ALog.error("Unable to download Feature Content", error: error)
				case .success(let url):
					DispatchQueue.main.async {
						self?.showPDFContent(url: url, title: task.featuredContentDetailViewImageLabel ?? task.title)
					}
				}
			}
		}
	}
}
