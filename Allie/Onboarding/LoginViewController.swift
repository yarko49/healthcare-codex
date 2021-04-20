//
//  LoginViewController.swift
//  Allie
//
//  Created by Waqar Malik on 4/18/21.
//

import SkyFloatingLabelTextField
import UIKit

class LoginViewController: SignupBaseViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		view.addSubview(titleLabel)
		NSLayoutConstraint.activate([titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: titleLabel.trailingAnchor, multiplier: 2.0),
		                             titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 10.0)])
		titleLabel.text = NSLocalizedString("LOGIN", comment: "Login")

		view.addSubview(buttonStackView)
		NSLayoutConstraint.activate([buttonStackView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: buttonStackView.trailingAnchor, multiplier: 2.0),
		                             buttonStackView.topAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 8.0)])
		buttonStackView.addArrangedSubview(appleSignInButton)
		buttonStackView.addArrangedSubview(googleSignInButton)

		view.addSubview(emailTextField)
		NSLayoutConstraint.activate([emailTextField.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: emailTextField.trailingAnchor, multiplier: 0.0),
		                             emailTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 30.0)])
		emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

		view.addSubview(bottomButton)
		NSLayoutConstraint.activate([bottomButton.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: bottomButton.trailingAnchor, multiplier: 2.0),
		                             view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: bottomButton.bottomAnchor, multiplier: 2.0)])
		bottomButton.setTitle(NSLocalizedString("LOG_IN", comment: "Log In"), for: .normal)
		bottomButton.addTarget(self, action: #selector(signupWithEmail(_:)), for: .touchUpInside)
	}

	let emailTextField: SkyFloatingLabelTextField = {
		let textField = SkyFloatingLabelTextField(frame: .zero)
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.heightAnchor.constraint(equalToConstant: 48.0).isActive = true
		textField.placeholder = NSLocalizedString("EMAIL", comment: "Email")
		textField.title = NSLocalizedString("EMAIL_ADDRESS", comment: "Email address")
		textField.errorColor = .systemRed
		textField.lineColor = .allieSeparator
		textField.selectedLineColor = .allieLighterGray
		textField.lineHeight = 1.0
		textField.selectedLineHeight = 1.0
		textField.textColor = .allieButtons
		textField.keyboardType = .emailAddress
		textField.autocorrectionType = .no
		textField.autocapitalizationType = .none
		textField.selectedTitleColor = .allieLighterGray
		return textField
	}()

	@IBAction func signupWithEmail(_ sender: Any?) {
		guard let email = emailTextField.text, !email.isEmpty else {
			return
		}
		authorizeWithEmail?(email, .signIn)
	}

	@IBAction func textFieldDidChange(_ textField: UITextField) {
		if let text = textField.text {
			if let floatingLabelTextField = textField as? SkyFloatingLabelTextField {
				if text.count < 3 || !text.contains("@") {
					bottomButton.isEnabled = false
					floatingLabelTextField.errorMessage = NSLocalizedString("INVALID_EMAIL_ADDRESS", comment: "Invalid Email address")
				} else {
					bottomButton.isEnabled = true
					floatingLabelTextField.errorMessage = ""
				}
			}
		}

		bottomButton.backgroundColor = bottomButton.isEnabled ? .allieButtons : UIColor.allieButtons.withAlphaComponent(0.5)
	}
}
