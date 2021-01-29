//
//  PrivacyPolicyViewController.swift
//  Alfred
//

import Foundation
import UIKit

class PrivacyPolicyViewController: BaseViewController {
	// MARK: Coordinator Actions

	var backBtnAction: (() -> Void)?

	// MARK: - Properties

	// MARK: - IBOutlets

	@IBOutlet var titleLbl: UILabel!
	@IBOutlet var descTextView: UITextView!

	// MARK: - Setup

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func setupView() {
		super.setupView()

		title = Str.privacyPolicy
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}

	override func localize() {
		super.localize()

		titleLbl.attributedText = Str.privacyPolicy.with(style: .bold28, andColor: .black, andLetterSpacing: 0.36)
		// TODO: Add text
		descTextView.attributedText = descTextView.text.with(style: .regular17, andColor: .black, andLetterSpacing: -0.408)
	}

	override func populateData() {
		super.populateData()
	}

	// MARK: - Actions

	@objc func backBtnTapped() {
		backBtnAction?()
	}
}
