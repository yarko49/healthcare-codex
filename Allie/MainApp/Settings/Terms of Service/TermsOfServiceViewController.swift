//
//  TermsOfServiceViewController.swift
//  Allie
//

import Foundation
import UIKit

class TermsOfServiceViewController: BaseViewController {
	// MARK: - IBOutlets

	@IBOutlet var titleLbl: UILabel!
	@IBOutlet var descTextView: UITextView!

	// MARK: - Setup

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		AnalyticsManager.send(event: .pageView, properties: [.name: "TermsOfServiceView"])
	}

	override func setupView() {
		super.setupView()

		title = Str.termsOfService
	}

	override func localize() {
		super.localize()

		titleLbl.attributedText = Str.termsOfService.with(style: .bold28, andColor: .black, andLetterSpacing: 0.36)
		// TODO: Add text
		descTextView.attributedText = descTextView.text.with(style: .regular17, andColor: .black, andLetterSpacing: -0.408)
	}
}
