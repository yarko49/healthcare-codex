//  Signup.swift
//  alfred-ios

import Firebase
import FirebaseAuth
import IQKeyboardManagerSwift
import UIKit

class SignupVC: BaseViewController, UITextViewDelegate, UIGestureRecognizerDelegate {
	var backBtnAction: (() -> Void)?
	var nextBtnAction: (() -> Void)?
	var goToTermsOfService: (() -> Void)?
	var goToPrivacyPolicy: (() -> Void)?
	var signUpWithEP: ((_ email: String, _ password: String) -> Void)?
	var alertAction: ((_ title: String?, _ detail: String?, _ textfield: TextfieldView) -> Void)?

	@IBOutlet var contentView: UIView!
	@IBOutlet var scrollView: UIScrollView!
	@IBOutlet var stackView: UIStackView!
	@IBOutlet var textView: UITextView!
	@IBOutlet var signupBtn: BottomButton!
	@IBOutlet var signupmessage: UILabel!
	@IBOutlet var emailView: TextfieldView!
	@IBOutlet var confirmView: TextfieldView!
	@IBOutlet var passwordView: TextfieldView!

	override func setupView() {
		super.setupView()
		let navBar = navigationController?.navigationBar
		navBar?.setBackgroundImage(UIImage(), for: .default)
		navBar?.shadowImage = UIImage()
		navBar?.isHidden = false
		navBar?.isTranslucent = false
		navBar?.layoutIfNeeded()
		title = Str.signup
		navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(backBtnTapped))
		navigationItem.leftBarButtonItem?.tintColor = UIColor.black

		emailView.setupValues(labelTitle: Str.emailAddress, text: "", textIsPassword: false)
		confirmView.setupValues(labelTitle: Str.confirmEmailAddress, text: "", textIsPassword: false)
		passwordView.setupValues(labelTitle: Str.password, text: "", textIsPassword: true)
		signupBtn.setAttributedTitle(Str.signup.uppercased().with(style: .regular17, andColor: .white, andLetterSpacing: 0.3), for: .normal)
		signupBtn.refreshCorners(value: 5)
		signupBtn.setupButton()
		setup()
		view.layoutIfNeeded()
	}

	func setup() {
		signupmessage.attributedText = Str.signupmsg.with(style: .regular17, andColor: .lightGrey, andLetterSpacing: -0.32)
		textView.delegate = self
		textView.linkTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.orange]
		let attrString = NSMutableAttributedString(string: Str.acceptingTSPP)
		attrString.setAttributes([NSAttributedString.Key.foregroundColor: UIColor.lightGrey, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16.0, weight: .regular)], range: NSRange(location: 0, length: attrString.length))
		attrString.addAttribute(NSAttributedString.Key.kern, value: -0.32, range: NSRange(location: 0, length: attrString.length))
		attrString.addAttribute(.link, value: "1", range: NSRange(location: 28, length: 20))
		attrString.addAttribute(.link, value: "2", range: NSRange(location: 52, length: 15))
		textView.attributedText = attrString
		textView.isEditable = false
		textView.isScrollEnabled = false
		textView.dataDetectorTypes = [.link]
		textView.isSelectable = true
		textView.textContainer.lineFragmentPadding = 0.0
		textView.textContainerInset = .zero
		textView.textAlignment = .center
	}

	func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
		if URL.absoluteString == "1" {
			goToTermsOfService?()
		} else if URL.absoluteString == "2" {
			goToPrivacyPolicy?()
		}
		return true
	}

	@IBAction func signupTapped(_ sender: Any) {
		guard let email = emailView.tfText, !email.isEmpty, email.isValidEmail() else {
			alertAction?(Str.invalidEmail, Str.enterEmail, emailView)
			return
		}

		guard let confirm = confirmView.tfText, !confirm.isEmpty, confirm == email else {
			alertAction?(Str.invalidEmail, Str.invalidConfirmationEmail, confirmView)
			return
		}

		guard let password = passwordView.tfText, !password.isEmpty else {
			alertAction?(Str.invalidPw, Str.enterPw, passwordView)
			return
		}

		signUpWithEP?(email, password)
	}

	@objc func backBtnTapped() {
		navigationController?.navigationBar.isHidden = true
		navigationController?.navigationBar.layoutIfNeeded()
		backBtnAction?()
	}

	@IBAction func signUpBtnTapped(_ sender: Any) {
		nextBtnAction?()
	}
}
