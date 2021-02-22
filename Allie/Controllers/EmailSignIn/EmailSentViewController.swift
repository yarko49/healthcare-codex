//
//  EmailSentViewController.swift
//  Allie
//
//  Created by Waqar Malik on 1/20/21.
//

import UIKit

class EmailSentViewController: BaseViewController {
	var openMailApp: Coordinator.ActionHandler?
	var goToTermsOfService: Coordinator.ActionHandler?
	var goToPrivacyPolicy: Coordinator.ActionHandler?

	var email: String = ""
	var authorizationFlowType: AuthorizationFlowType = .signIn

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .onboardingBackground
		title = Str.emailSent
		termsOfServiceTextView.delegate = self
		termsOfServiceTextView.backgroundColor = view.backgroundColor
		termsOfServiceTextView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(termsOfServiceTextView)
		NSLayoutConstraint.activate([termsOfServiceTextView.widthAnchor.constraint(equalToConstant: 286.0),
		                             termsOfServiceTextView.heightAnchor.constraint(equalToConstant: 40.0),
		                             termsOfServiceTextView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
		                             view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: termsOfServiceTextView.bottomAnchor, multiplier: 0.0)])
		view.addSubview(mailButton)
		NSLayoutConstraint.activate([mailButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
		                             view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: mailButton.bottomAnchor, multiplier: 10.0)])
		mailButton.addTarget(self, action: #selector(openMailAppTapped(_:)), for: .touchUpInside)

		illustrationView.translatesAutoresizingMaskIntoConstraints = false
		illustrationView.titleLabel.attributedText = Str.checkMail.with(style: .bold17, andColor: .black, andLetterSpacing: -0.32)
		illustrationView.subtitleLabel.attributedText = (authorizationFlowType == .signIn ? Str.sentEmailAtSignIn(email).with(style: .regular17, andColor: .lightGrey, andLetterSpacing: -0.32) :
			Str.sentEmailAtSignUp(email).with(style: .regular17, andColor: .lightGrey, andLetterSpacing: -0.32))
		view.addSubview(illustrationView)
		NSLayoutConstraint.activate([illustrationView.heightAnchor.constraint(equalToConstant: 450.0),
		                             illustrationView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 0.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: illustrationView.trailingAnchor, multiplier: 0.0),
		                             mailButton.topAnchor.constraint(equalToSystemSpacingBelow: illustrationView.bottomAnchor, multiplier: 1.0)])
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		AnalyticsManager.send(event: .pageView, properties: [.name: "EmailSentView", .authFlowType: authorizationFlowType])
	}

	private let mailButton: UIButton = {
		let button = UIButton(type: .custom)
		button.backgroundColor = .grey
		button.layer.cornerRadius = 5.0
		button.layer.cornerCurve = .continuous
		let title = Str.openMailApp.uppercased()
		let attributes: [NSAttributedString.Key: Any] = [.kern: 5.0, .foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 17.0, weight: .semibold)]
		let attributedText = NSAttributedString(string: title, attributes: attributes)
		button.setAttributedTitle(attributedText, for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.heightAnchor.constraint(equalToConstant: 68.0).isActive = true
		button.widthAnchor.constraint(equalToConstant: 300.0).isActive = true
		return button
	}()

	let termsOfServiceTextView: UITextView = {
		let view = UITextView(frame: .zero)
		view.linkTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.orange]
		let attrString = NSMutableAttributedString(string: Str.acceptingTSPP)
		attrString.setAttributes([NSAttributedString.Key.foregroundColor: UIColor.lightGrey, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16.0, weight: .regular)], range: NSRange(location: 0, length: attrString.length))
		attrString.addAttribute(NSAttributedString.Key.kern, value: -0.32, range: NSRange(location: 0, length: attrString.length))
		attrString.addAttribute(.link, value: "1", range: NSRange(location: 28, length: 20))
		attrString.addAttribute(.link, value: "2", range: NSRange(location: 52, length: 15))
		view.attributedText = attrString
		view.isEditable = false
		view.isScrollEnabled = false
		view.dataDetectorTypes = [.link]
		view.isSelectable = true
		view.textContainer.lineFragmentPadding = 0.0
		view.textContainerInset = .zero
		view.textAlignment = .center
		return view
	}()

	let illustrationView: IllustrationView = {
		let view = IllustrationView(frame: .zero)
		view.imageView.image = UIImage(named: "illustration4-1")
		view.titleLabel.text = Str.checkMail
		view.subtitleLabel.numberOfLines = 0
		return view
	}()

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
