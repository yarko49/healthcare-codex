//
//  AccountDetailsViewController.swift
//  Allie
//

import Foundation
import UIKit

class AccountDetailsViewController: BaseViewController {
	// MARK: Coordinator Actions

	var resetPasswordAction: (() -> Void)?

	// MARK: - Properties

	var firstNameTextView = TextfieldView()
	var lastNameTextView = TextfieldView()
	var emailTextView = TextfieldView()

	// MARK: - IBOutlets

	@IBOutlet var textfieldStackView: UIStackView!
	@IBOutlet var passwordLabel: UILabel!
	@IBOutlet var passwordTextField: UITextField!

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		AnalyticsManager.send(event: .pageView, properties: [.name: "AccountsDetailsView"])
	}

	// MARK: - Setup

	override func setupView() {
		super.setupView()

		title = Str.accountDetails

		let firstName = DataContext.shared.userModel?.displayFirstName ?? ""
		let lastName = DataContext.shared.userModel?.displayLastName ?? ""
		guard let email = DataContext.shared.userModel?.email else { return }

		firstNameTextView.setupValues(labelTitle: Str.firstName, text: firstName, textIsPassword: false)
		lastNameTextView.setupValues(labelTitle: Str.lastName, text: lastName, textIsPassword: false)
		emailTextView.setupValues(labelTitle: Str.email, text: email, textIsPassword: false)

		textfieldStackView.addArrangedSubview(firstNameTextView)
		textfieldStackView.addArrangedSubview(lastNameTextView)
		textfieldStackView.addArrangedSubview(emailTextView)
		passwordTextField.isUserInteractionEnabled = false
	}

	override func localize() {
		super.localize()

		passwordLabel.attributedText = Str.password.with(style: .regular13, andColor: .lightGrey, andLetterSpacing: -0.078)
		passwordTextField.isSecureTextEntry = true
		passwordTextField.attributedText = "1234567890".with(style: .regular17, andColor: .black, andLetterSpacing: 0.38)
	}

	// MARK: - Actions

	@IBAction func passwordResetTapped(_ sender: Any) {
		resetPasswordAction?()
	}
}
