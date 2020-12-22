//
//  EmailSignInVC.swift
//  alfred-ios

import FirebaseAuth
import Foundation
import UIKit

class EmailSignInVC: BaseViewController {
	// MARK: - Coordinator Actions

	var backBtnAction: (() -> Void)?
	var signInWithEmail: ((_ email: String) -> Void)?
	var alertAction: ((_ title: String?, _ detail: String?, _ textfield: TextfieldView) -> Void)?

	// MARK: - IBOutlets

	@IBOutlet var emailView: TextfieldView!
	@IBOutlet var signInBtn: UIButton!

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
		setup()
		view.layoutIfNeeded()
	}

	func setup() {
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

		signInWithEmail?(email)
	}

	@objc func backBtnTapped() {
		navigationController?.navigationBar.isHidden = true
		navigationController?.navigationBar.layoutIfNeeded()
		backBtnAction?()
	}
}
