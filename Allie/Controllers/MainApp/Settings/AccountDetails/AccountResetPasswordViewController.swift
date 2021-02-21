//
//  AccountResetPasswordViewController.swift
//  Allie
//

import Foundation
import UIKit

class AccountResetPasswordViewController: BaseViewController {
	// MARK: Coordinator Actions

	var sendEmailAction: ((_ email: String?) -> Void)?

	// MARK: - IBOutlets

	@IBOutlet var resetPasswordView: UIView!
	@IBOutlet var textfieldStackView: UIStackView!
	@IBOutlet var sendButton: RoundedButton!
	@IBOutlet var resetPasswordDescLabel: UILabel!
	@IBOutlet var completionLabel: UILabel!
	@IBOutlet var emailTextField: TextfieldView!

	// MARK: - Setup

	override func setupView() {
		super.setupView()
		title = Str.resetPassword
		emailTextField.setupValues(labelTitle: Str.emailAddress, text: "", textIsPassword: false)
		completionLabel.isHidden = true
		sendButton.cornerRadius = 29
		sendButton.roundedBorderColor = UIColor.grey
		sendButton.roundedBackgroundColor = UIColor.white
	}

	override func localize() {
		super.localize()

		resetPasswordDescLabel.attributedText = Str.resetPasswordDesc.with(style: .regular17, andColor: .lightGrey, andLetterSpacing: -0.408)
		sendButton.setAttributedTitle(Str.send.uppercased().with(style: .regular17, andColor: .grey, andLetterSpacing: 3), for: .normal)
		completionLabel.attributedText = Str.resetPasswordResponse.with(style: .regular17, andColor: .lightGrey, andLetterSpacing: -0.408)
	}

	func showCompletionMessage() {
		completionLabel.isHidden = false
		resetPasswordView.isHidden = true
	}

	// MARK: - Actions

	@IBAction func passwordResetTapped(_ sender: Any) {
		sendEmailAction?(emailTextField.text)
	}
}
