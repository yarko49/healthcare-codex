//
//  UIViewController+DetailView.swift
//  Allie
//
//  Created by Waqar Malik on 2/24/21.
//

import CareKit
import CareKitStore
import SafariServices
import SDWebImage
import UIKit

extension UIViewController {
	func showHTMLCSSContent(title: String?, html: String?, css: String?, image: UIImage?, imageURL: URL?) {
		guard let html = html else {
			return
		}

		let detailViewController = OCKDetailViewController(html: .init(html: html, css: css), imageOverlayStyle: .unspecified, showsCloseButton: false)
		detailViewController.detailView.imageView.image = image
		detailViewController.detailView.imageLabel.text = title
		detailViewController.detailView.imageLabel.textColor = .white
		if imageURL != nil {
			detailViewController.detailView.imageView.sd_setImage(with: imageURL, placeholderImage: image, options: [], context: nil)
		}
		navigationController?.showDetailViewController(detailViewController, sender: self)
	}

	func showTextContent(title: String?, content: String, image: UIImage?, imageURL: URL?) {
		let textContentViewController = TextContentDetailViewController(nibName: nil, bundle: nil)
		textContentViewController.titleLabel.text = title
		textContentViewController.textView.text = content
		textContentViewController.image = image
		textContentViewController.imageURL = imageURL
		let navController = UINavigationController(rootViewController: textContentViewController)
		navigationController?.showDetailViewController(navController, sender: self)
	}

	func showURLContent(url: URL) {
		guard url.absoluteString.hasPrefix("http") else {
			return
		}
		let safariViewController = SFSafariViewController(url: url)
		navigationController?.showDetailViewController(safariViewController, sender: self)
	}

	func showPDFContent(url: URL, title: String?) {
		let pdfViewController = PDFViewController()
		pdfViewController.pdfContentURL = url
		pdfViewController.title = title
		let navController = UINavigationController(rootViewController: pdfViewController)
		navigationController?.showDetailViewController(navController, sender: self)
	}
}
