//
//  FeaturedContentDetailViewController.swift
//  Allie
//
//  Created by Waqar Malik on 2/5/21.
//

import UIKit

class FeaturedContentDetailViewController: UIViewController {
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		AnalyticsManager.send(event: .pageView, properties: [.name: "FeaturedContentDetailView"])
	}

	let imageView: UIImageView = {
		let view = UIImageView(frame: .zero)
		view.clipsToBounds = true
		view.contentMode = .scaleAspectFill
		return view
	}()

	let textView: UITextView = {
		let view = UITextView(frame: .zero)
		view.showsVerticalScrollIndicator = false
		view.showsHorizontalScrollIndicator = false
		view.textColor = .darkText
		return view
	}()
}
