//
//  AuthenticationOptionsView.swift
//  Allie
//
//  Created by Waqar Malik on 1/8/21.
//

import AuthenticationServices
import UIKit

enum AuthenticationProviderType: Hashable, CaseIterable {
	case apple
	case google
	case email
}

protocol AuthenticationOptionsViewDelegate: AnyObject {
	func authenticationOptionsView(_ view: AuthenticationOptionsView, didSelectProvider provider: AuthenticationProviderType)
	func authenticationOptionsViewDidCancel(_ view: AuthenticationOptionsView)
}

class AuthenticationOptionsView: UIView {
	static let height: CGFloat = 310.0
	weak var delegate: AuthenticationOptionsViewDelegate?

	init(frame: CGRect, authorizationFlowType: AuthorizationFlowType = .signIn) {
		self.authorizationFlowType = authorizationFlowType
		super.init(frame: frame)
		configureView(frame: frame)
	}

	@available(*, unavailable)
	override init(frame: CGRect) {
		fatalError("init(coder:) has not been implemented")
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	let authorizationFlowType: AuthorizationFlowType

	let barView: UIView = {
		let view = UIView(frame: .zero)
		view.backgroundColor = UIColor.swipe
		view.layer.cornerRadius = 2.0
		view.layer.cornerCurve = .continuous
		view.clipsToBounds = true
		view.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([view.heightAnchor.constraint(equalToConstant: 4.0)])
		return view
	}()

	let modeLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.textColor = .black
		label.font = UIFont.systemFont(ofSize: 17.0, weight: .semibold)
		return label
	}()

	let cancelButton: UIButton = {
		let button = UIButton(type: .custom)
		button.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([button.widthAnchor.constraint(equalToConstant: 64.0),
		                             button.heightAnchor.constraint(equalToConstant: 36.0)])
		button.setTitle(NSLocalizedString("CANCEL", comment: "Cancel"), for: .normal)
		button.setTitleColor(.lightGray, for: .normal)
		button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
		return button
	}()

	private var buttonStackView: UIStackView = {
		let view = UIStackView(frame: .zero)
		view.axis = .vertical
		view.spacing = 16.0
		view.distribution = .fill
		view.alignment = .fill
		return view
	}()

	private(set) lazy var appleSignInButton: ASAuthorizationAppleIDButton = {
		let button = ASAuthorizationAppleIDButton(type: self.authorizationFlowType.appleAuthButtonType, style: .black)
		button.cornerRadius = 5.0
		button.layer.cornerCurve = .continuous
		return button
	}()

	@IBAction private func authenticateApple(_ sender: Any) {
		delegate?.authenticationOptionsView(self, didSelectProvider: .apple)
	}

	private(set) lazy var googleSignInButton: UIButton = {
		let button = UIButton.googleSignInButton
		button.layer.cornerRadius = 5.0
		button.layer.cornerCurve = .continuous
		let title = authorizationFlowType.googleButtonTitle
		button.setTitle(title, for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()

	@IBAction private func authenticateGoogle(_ sender: Any) {
		delegate?.authenticationOptionsView(self, didSelectProvider: .google)
	}

	private(set) lazy var emailSignInButton: UIButton = {
		let button = UIButton.emailSignInButton
		button.layer.cornerRadius = 5.0
		button.layer.cornerCurve = .continuous
		let title = authorizationFlowType.emailButtonTitle
		button.setTitle(title, for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()

	@IBAction private func authenticateEmail(_ sender: Any) {
		delegate?.authenticationOptionsView(self, didSelectProvider: .email)
	}

	@IBAction private func cancel(_ sender: Any) {
		delegate?.authenticationOptionsViewDidCancel(self)
	}

	private func configureView(frame: CGRect) {
		translatesAutoresizingMaskIntoConstraints = false
		backgroundColor = .white
		layer.cornerRadius = 16.0
		layer.cornerCurve = .continuous
		layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		clipsToBounds = true

		modeLabel.translatesAutoresizingMaskIntoConstraints = false
		modeLabel.text = authorizationFlowType.modalTitle
		addSubview(modeLabel)
		NSLayoutConstraint.activate([modeLabel.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 2.5),
		                             modeLabel.widthAnchor.constraint(equalToConstant: 60.0),
		                             modeLabel.heightAnchor.constraint(equalToConstant: 36.0),
		                             modeLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 4.25)])

		addSubview(barView)
		NSLayoutConstraint.activate([barView.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 1.0),
		                             barView.widthAnchor.constraint(equalToConstant: 80.0),
		                             barView.centerXAnchor.constraint(equalTo: centerXAnchor)])

		addSubview(cancelButton)
		NSLayoutConstraint.activate([cancelButton.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 2.5),
		                             trailingAnchor.constraint(equalToSystemSpacingAfter: cancelButton.trailingAnchor, multiplier: 4.25)])

		cancelButton.addTarget(self, action: #selector(cancel(_:)), for: .touchUpInside)

		buttonStackView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(buttonStackView)
		NSLayoutConstraint.activate([buttonStackView.topAnchor.constraint(equalToSystemSpacingBelow: cancelButton.bottomAnchor, multiplier: 3.0),
		                             buttonStackView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 5.0),
		                             trailingAnchor.constraint(equalToSystemSpacingAfter: buttonStackView.trailingAnchor, multiplier: 5.0),
		                             bottomAnchor.constraint(equalToSystemSpacingBelow: buttonStackView.bottomAnchor, multiplier: 6.0)])

		buttonStackView.addArrangedSubview(appleSignInButton)
		appleSignInButton.addTarget(self, action: #selector(authenticateApple(_:)), for: .touchUpInside)
		buttonStackView.addArrangedSubview(googleSignInButton)
		googleSignInButton.addTarget(self, action: #selector(authenticateGoogle(_:)), for: .touchUpInside)
		buttonStackView.addArrangedSubview(emailSignInButton)
		emailSignInButton.addTarget(self, action: #selector(authenticateEmail(_:)), for: .touchUpInside)
	}
}
