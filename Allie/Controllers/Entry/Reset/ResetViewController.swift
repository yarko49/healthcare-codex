//
//  ResetViewController.swift
//  Allie

import FirebaseAuth
import Foundation
import UIKit

class ResetViewController: BaseViewController {
	// MARK: - Coordinator Actions

	var nextAction: ((_ email: String?) -> Void)?

	// MARK: - IBOutlets

	@IBOutlet var scrollView: UIScrollView!
	@IBOutlet var saveButton: UIButton!
	@IBOutlet var resetLabel: UILabel!
	@IBOutlet var stackView: UIStackView!
	@IBOutlet var emailTextfieldView: TextfieldView!

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		AnalyticsManager.send(event: .pageView, properties: [.name: "ResetView"])
	}

	override func setupView() {
		super.setupView()
		title = "Reset Password"
		saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
		setup()
	}

	func setup() {
		emailTextfieldView.setupValues(labelTitle: Str.emailAddress, text: "", textIsPassword: false)
		let attrText = Str.save.with(style: .regular17, andColor: UIColor.grey, andLetterSpacing: 3)
		saveButton.setAttributedTitle(attrText, for: .normal)
		saveButton.layer.cornerRadius = 28.5
		saveButton.backgroundColor = UIColor.white
		saveButton.layer.borderWidth = 2.0
		saveButton.layer.borderColor = UIColor.grey.cgColor
		resetLabel.attributedText = Str.resetMessage.with(style: .regular17, andColor: .lightGray, andLetterSpacing: -0.408)
		resetLabel.numberOfLines = 0
	}

	@IBAction func saveButtonTapped(_ sender: Any) {
		nextAction?(emailTextfieldView.text)
	}
}
