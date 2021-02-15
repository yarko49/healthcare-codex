//
//  PrivacyPolicyViewController.swift
//  Allie
//

import Foundation
import UIKit

class PrivacyPolicyViewController: BaseViewController {
	// MARK: - Properties

	// MARK: - IBOutlets

	@IBOutlet var titleLbl: UILabel!
	@IBOutlet var descTextView: UITextView!

	// MARK: - Setup

	override func setupView() {
		super.setupView()

		title = Str.privacyPolicy
	}

	override func localize() {
		super.localize()

		titleLbl.attributedText = Str.privacyPolicy.with(style: .bold28, andColor: .black, andLetterSpacing: 0.36)
		// TODO: Add text
		descTextView.attributedText = descTextView.text.with(style: .regular17, andColor: .black, andLetterSpacing: -0.408)
	}
}
