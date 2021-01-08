//
//  EmailSentViewController.swift
//  Alfred
//

import Foundation
import UIKit

class EmailSentViewController: BaseViewController {
	// MARK: - Coordinator Actions

	// MARK: - Properties

	var backBtnAction: (() -> Void)?
	var openMailApp: (() -> Void)?
	var goToTermsOfService: (() -> Void)?
	var goToPrivacyPolicy: (() -> Void)?

	// MARK: - IBOutlets

	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var descLabel: UILabel!
	@IBOutlet var mailButton: BottomButton!
	@IBOutlet var tosTextView: UITextView!

	var email: String = ""
	var purpose: SendEmailPurpose = .signIn

	// MARK: - Setup

	override func setupView() {
		super.setupView()

		title = Str.emailSent
		navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(backBtnTapped))
		navigationItem.leftBarButtonItem?.tintColor = UIColor.black

		setupToS()
	}

	override func localize() {
		super.localize()

		titleLabel.attributedText = Str.checkMail.with(style: .bold17, andColor: .black, andLetterSpacing: -0.32)
		descLabel.attributedText = purpose == .signIn ? Str.sentEmailAtSignIn(email).with(style: .regular17, andColor: .lightGrey, andLetterSpacing: -0.32) : Str.sentEmailAtSignUp(email).with(style: .regular17, andColor: .lightGrey, andLetterSpacing: -0.32)
		mailButton.setAttributedTitle(Str.openMailApp.uppercased().with(style: .semibold17, andColor: .white), for: .normal)
		mailButton.refreshCorners(value: 5)
		mailButton.setupButton()
	}

	func setupToS() {
		tosTextView.delegate = self
		tosTextView.linkTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.orange]
		let attrString = NSMutableAttributedString(string: Str.acceptingTSPP)
		attrString.setAttributes([NSAttributedString.Key.foregroundColor: UIColor.lightGrey, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16.0, weight: .regular)], range: NSRange(location: 0, length: attrString.length))
		attrString.addAttribute(NSAttributedString.Key.kern, value: -0.32, range: NSRange(location: 0, length: attrString.length))
		attrString.addAttribute(.link, value: "1", range: NSRange(location: 28, length: 20))
		attrString.addAttribute(.link, value: "2", range: NSRange(location: 52, length: 15))
		tosTextView.attributedText = attrString
		tosTextView.isEditable = false
		tosTextView.isScrollEnabled = false
		tosTextView.dataDetectorTypes = [.link]
		tosTextView.isSelectable = true
		tosTextView.textContainer.lineFragmentPadding = 0.0
		tosTextView.textContainerInset = .zero
		tosTextView.textAlignment = .center
	}

	@objc func backBtnTapped() {
		backBtnAction?()
	}

	@IBAction func openMailAppTapped(_ sender: Any) {
		openMailApp?()
	}
}

extension EmailSentViewController: UITextViewDelegate {
	func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
		if URL.absoluteString == "1" {
			goToTermsOfService?()
		} else if URL.absoluteString == "2" {
			goToPrivacyPolicy?()
		}
		return true
	}
}
