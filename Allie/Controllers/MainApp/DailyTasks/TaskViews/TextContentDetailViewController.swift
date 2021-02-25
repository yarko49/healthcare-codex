//
//  TextContentDetailViewController.swift
//  Allie
//
//  Created by Waqar Malik on 2/5/21.
//

import SDWebImage
import UIKit

class TextContentDetailViewController: UIViewController {
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		AnalyticsManager.send(event: .pageView, properties: [.name: "FeaturedContentDetailView"])
	}

	var imageURL: URL? {
		didSet {
			imageView.sd_setImage(with: imageURL, completed: nil)
		}
	}

	let imageView: UIImageView = {
		let view = UIImageView(frame: .zero)
		view.clipsToBounds = true
		view.contentMode = .scaleAspectFill
		return view
	}()

	let titleLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.font = UIFont.preferredFont(forTextStyle: .title1)
		label.textColor = .white
		return label
	}()

	let textView: UITextView = {
		let view = UITextView(frame: .zero)
		view.showsVerticalScrollIndicator = false
		view.showsHorizontalScrollIndicator = false
		view.textColor = .darkText
		view.isEditable = false
		view.isSelectable = false
		return view
	}()

	override func viewDidLoad() {
		super.viewDidLoad()

		imageView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(imageView)
		NSLayoutConstraint.activate([imageView.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 0.0),
		                             imageView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 0.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: imageView.trailingAnchor, multiplier: 0.0),
		                             imageView.heightAnchor.constraint(equalToConstant: 300.0)])

		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(titleLabel)
		NSLayoutConstraint.activate([titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: titleLabel.trailingAnchor, multiplier: 2.0),
		                             imageView.bottomAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 3.0)])

		textView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(textView)
		NSLayoutConstraint.activate([textView.topAnchor.constraint(equalToSystemSpacingBelow: imageView.bottomAnchor, multiplier: 0.0),
		                             textView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 0.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: textView.trailingAnchor, multiplier: 0.0),
		                             view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: textView.bottomAnchor, multiplier: 0.0)])
	}
}
