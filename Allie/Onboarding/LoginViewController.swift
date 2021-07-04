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
		titleLabel.text = NSLocalizedString("LOGIN", comment: "Login")

		view.addSubview(buttonStackView)
		NSLayoutConstraint.activate([buttonStackView.widthAnchor.constraint(equalToConstant: buttonWidth),
		                             buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
		                             buttonStackView.topAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 8.0)])
		buttonStackView.addArrangedSubview(appleIdButton)
		buttonStackView.addArrangedSubview(googleSignInButton)

		view.addSubview(emailTextField)
		NSLayoutConstraint.activate([emailTextField.widthAnchor.constraint(equalToConstant: buttonWidth),
		                             emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
		                             emailTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 30.0)])
		emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

		view.addSubview(bottomButton)
		NSLayoutConstraint.activate([bottomButton.widthAnchor.constraint(equalToConstant: buttonWidth),
		                             bottomButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
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
		textField.textColor = .allieGray
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

		bottomButton.backgroundColor = bottomButton.isEnabled ? .allieGray : UIColor.allieGray.withAlphaComponent(0.5)
	}
}
