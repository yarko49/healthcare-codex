//
//  EmailSignInVC.swift
//  alfred-ios

import FirebaseAuth
import Foundation
import UIKit

class EmailSignInVC: BaseVC {
	// MARK: - Coordinator Actions

	var backBtnAction: (() -> Void)?
	var resetPasswordAction: (() -> Void)?
	var signInWithEP: ((_ email: String, _ password: String) -> Void)?
	var alertAction: ((_ title: String?, _ detail: String?, _ textfield: TextfieldView) -> Void)?

	// MARK: - IBOutlets

	@IBOutlet var screen: UIView!
	@IBOutlet var signInBtn: UIButton!
	@IBOutlet var forgotPasswordBtn: UIButton!
	@IBOutlet var stackView: UIStackView!
	@IBOutlet var emailView: TextfieldView!
	@IBOutlet var passwordView: TextfieldView!

	override func setupView() {
		super.setupView()
		navigationController?.navigationBar.isHidden = false
		let navBar = navigationController?.navigationBar
		navBar?.setBackgroundImage(UIImage(), for: .default)
		navBar?.shadowImage = UIImage()
		navBar?.isHidden = false
		navBar?.isTranslucent = false
		title = Str.welcomeBack
		navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(backBtnTapped))
		navigationItem.leftBarButtonItem?.tintColor = UIColor.black
		emailView.setupValues(labelTitle: Str.email, text: "", textIsPassword: false)
		emailView.textfield.keyboardType = .emailAddress
		emailView.textfield.autocapitalizationType = .none
		emailView.textfield.autocorrectionType = .no
		passwordView.setupValues(labelTitle: Str.password, text: "", textIsPassword: true)
		forgotPasswordBtn.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)
		setup()
		view.layoutIfNeeded()
	}

	func setup() {
		let forgotPassword = UILabel()
		forgotPassword.attributedText = Str.forgotPassword.with(style: .regular17, andColor: UIColor.lightGrey, andLetterSpacing: -0.408)
		forgotPasswordBtn.setAttributedTitle(forgotPassword.attributedText, for: .normal)
		let signIn = UILabel()
		signIn.attributedText = Str.signin.with(style: .regular17, andColor: UIColor.white, andLetterSpacing: 3)
		signInBtn.setAttributedTitle(signIn.attributedText, for: .normal)
		signInBtn.layer.cornerRadius = 5
		signInBtn.backgroundColor = UIColor.grey
	}

	@IBAction func signInBtnTapped(_ sender: Any) {
		guard let email = emailView.tfText, !email.isEmpty, email.isValidEmail() else {
			alertAction?(Str.invalidEmail, Str.enterEmail, emailView)
			return
		}

		guard let password = passwordView.tfText, !password.isEmpty else {
			alertAction?(Str.invalidPw, Str.enterPw, passwordView)
			return
		}

		signInWithEP?(email, password)
	}

	@objc func forgotPasswordTapped() {
		resetPasswordAction?()
	}

	@objc func backBtnTapped() {
		navigationController?.navigationBar.isHidden = true
		navigationController?.navigationBar.layoutIfNeeded()
		backBtnAction?()
	}
}
