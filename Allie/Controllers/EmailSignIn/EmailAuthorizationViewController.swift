//
//  EmailAuthorizationViewController.swift
//  Allie
//
//  Created by Waqar Malik on 1/19/21.
//

import UIKit

class EmailAuthorizationViewController: BaseViewController {
	var authorizeWithEmail: ((_ email: String, _ type: AuthorizationFlowType) -> Void)?
	var alertAction: ((_ title: String?, _ detail: String?, _ textfield: TitledTextField) -> Void)?
	var goToTermsOfService: Coordinator.ActionHandler?
	var goToPrivacyPolicy: Coordinator.ActionHandler?

	var authorizationFlowType: AuthorizationFlowType = .signIn

	override func viewDidLoad() {
		super.viewDidLoad()
		title = authorizationFlowType == .signIn ? Str.welcomeBack : Str.signup
		view.backgroundColor = .onboardingBackground
		messageLabel.text = authorizationFlowType == .signUp ? Str.signupmsg : nil
		messageLabel.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(messageLabel)
		NSLayoutConstraint.activate([messageLabel.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 6.0),
		                             messageLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 3.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: messageLabel.trailingAnchor, multiplier: 3.0)])

		termsOfServiceTextView.delegate = self
		termsOfServiceTextView.backgroundColor = view.backgroundColor
		termsOfServiceTextView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(termsOfServiceTextView)
		NSLayoutConstraint.activate([termsOfServiceTextView.widthAnchor.constraint(equalToConstant: 286.0),
		                             termsOfServiceTextView.heightAnchor.constraint(equalToConstant: 40.0),
		                             termsOfServiceTextView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
		                             view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: termsOfServiceTextView.bottomAnchor, multiplier: 0.0)])

		emailTextField.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(emailTextField)
		NSLayoutConstraint.activate([emailTextField.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 10.0),
		                             emailTextField.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 3.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: emailTextField.trailingAnchor, multiplier: 3.0)])
		signInButton.addTarget(self, action: #selector(signInButtonTapped(_:)), for: .touchUpInside)
		view.addSubview(signInButton)
		NSLayoutConstraint.activate([signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
		                             view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: signInButton.bottomAnchor, multiplier: 10.0)])

		if authorizationFlowType == .signIn {
			emailTextField.text = Keychain.emailForLink
		}
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		AnalyticsManager.send(event: .pageView, properties: [.name: "EmailAuthorizationView", .authFlowType: authorizationFlowType])
	}

	let messageLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.font = UIFont.preferredFont(forTextStyle: .body)
		label.textColor = .lightGrey
		label.textAlignment = .center
		return label
	}()

	let emailTextField: TitledTextField = {
		let view = TitledTextField(frame: .zero)
		view.textfield.keyboardType = .emailAddress
		view.textfield.autocapitalizationType = .none
		view.textfield.autocorrectionType = .no
		view.title = Str.email
		return view
	}()

	private let signInButton: UIButton = {
		let button = UIButton(type: .custom)
		button.backgroundColor = .grey
		button.layer.cornerRadius = 5.0
		button.layer.cornerCurve = .continuous
		let title = Str.sendLink.uppercased()
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

	@IBAction func signInButtonTapped(_ sender: Any) {
		guard let email = emailTextField.text, !email.isEmpty, email.isValidEmail() else {
			alertAction?(Str.invalidEmail, Str.enterEmail, emailTextField)
			return
		}
		authorizeWithEmail?(email, authorizationFlowType)
	}
}

extension EmailAuthorizationViewController: UITextViewDelegate {
	func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
		if URL.absoluteString == "1" {
			goToTermsOfService?()
		} else if URL.absoluteString == "2" {
			goToPrivacyPolicy?()
		}
		return true
	}
}
