//
//  EmailSignInVC.swift
//  Alfred

import FirebaseAuth
import Foundation
import UIKit

class EmailSignInViewController: BaseViewController {
	// MARK: - Coordinator Actions

	var backButtonAction: (() -> Void)?
	var signInWithEmail: ((_ email: String) -> Void)?
	var alertAction: ((_ title: String?, _ detail: String?, _ textfield: TextfieldView) -> Void)?

	// MARK: - IBOutlets

	@IBOutlet var emailTextfieldView: TextfieldView!
	@IBOutlet var signInButton: UIButton!

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
		emailTextfieldView.setupValues(labelTitle: Str.email, text: "", textIsPassword: false)
		emailTextfieldView.textfield.keyboardType = .emailAddress
		emailTextfieldView.textfield.autocapitalizationType = .none
		emailTextfieldView.textfield.autocorrectionType = .no
		setup()
		view.layoutIfNeeded()
	}

	func setup() {
		let title = Str.signin.with(style: .regular17, andColor: UIColor.white, andLetterSpacing: 3)
		signInButton.setAttributedTitle(title, for: .normal)
		signInButton.layer.cornerRadius = 5
		signInButton.backgroundColor = UIColor.grey
	}

	@IBAction func signInButtonTapped(_ sender: Any) {
		guard let email = emailTextfieldView.tfText, !email.isEmpty, email.isValidEmail() else {
			alertAction?(Str.invalidEmail, Str.enterEmail, emailTextfieldView)
			return
		}

		signInWithEmail?(email)
	}

	@objc func backBtnTapped() {
		navigationController?.navigationBar.isHidden = true
		navigationController?.navigationBar.layoutIfNeeded()
		backButtonAction?()
	}
}
