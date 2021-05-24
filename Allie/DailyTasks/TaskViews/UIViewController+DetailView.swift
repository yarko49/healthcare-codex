//
//  UIViewController+DetailView.swift
//  Allie
//
//  Created by Waqar Malik on 2/24/21.
//

import CareKit
import SafariServices
import SDWebImage
import UIKit

extension UIViewController {
	func showHTMLCSSContent(title: String?, html: String?, css: String?, imageURL: URL?) {
		guard let html = html else {
			return
		}

		let detailViewController = OCKDetailViewController(html: .init(html: html, css: css), imageOverlayStyle: .unspecified, showsCloseButton: false)
		detailViewController.detailView.imageView.sd_setImage(with: imageURL, completed: nil)
		detailViewController.detailView.imageLabel.text = title
		detailViewController.detailView.imageLabel.textColor = .white
		navigationController?.show(detailViewController, sender: self)
	}

	func showTextContent(title: String?, content: String, imageURL: URL?) {
		let textContentViewController = TextContentDetailViewController(nibName: nil, bundle: nil)
		textContentViewController.titleLabel.text = title
		textContentViewController.textView.text = content
		textContentViewController.imageURL = imageURL
		navigationController?.show(textContentViewController, sender: self)
	}

	func showURLContent(url: URL) {
		guard url.absoluteString.hasPrefix("http") else {
			return
		}
		let safariViewController = SFSafariViewController(url: url)
		navigationController?.present(safariViewController, animated: true, completion: nil)
	}
}
