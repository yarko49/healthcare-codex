//
//  SignupBaseViewController.swift
//  Allie
//
//  Created by Waqar Malik on 4/18/21.
//

import AuthenticationServices
import GoogleSignIn
import UIKit

class SignupBaseViewController: BaseViewController {
	var buttonHeight: CGFloat {
		view.frame.height < 700 ? 42.0 : 48.0
	}

	var authorizeWithEmail: ((_ email: String, _ authorizationFlowType: AuthorizationFlowType) -> Void)?
	var appleAuthoizationAction: Coordinable.ActionHandler?
	var emailAuthorizationAction: ((AuthorizationFlowType) -> Void)?
	var authorizationFlowChangedAction: ((AuthorizationFlowType) -> Void)?

	var authorizationFlowType: AuthorizationFlowType = .signUp {
		didSet {
			updateLabels()
		}
	}

	private(set) lazy var titleLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = .allieBlack
		label.textAlignment = .center
		label.text = NSLocalizedString("LOGIN", comment: "Login")
		label.font = UIFont.systemFont(ofSize: 26.0, weight: .bold)
		return label
	}()

	private(set) lazy var buttonStackView: UIStackView = {
		let stackView = UIStackView(frame: .zero)
		stackView.axis = .vertical
		stackView.distribution = .fill
		stackView.alignment = .fill
		stackView.spacing = 16.0
		stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		GIDSignIn.sharedInstance()?.presentingViewController = self
		appleSignInButton.addTarget(self, action: #selector(authenticateApple(_:)), for: .touchUpInside)
		googleSignInButton.addTarget(self, action: #selector(authenticateGoogle(_:)), for: .touchUpInside)
	}

	private(set) lazy var appleSignInButton: ASAuthorizationAppleIDButton = {
		let button = ASAuthorizationAppleIDButton(type: self.authorizationFlowType.appleAuthButtonType, style: .whiteOutline)
		button.cornerRadius = 8.0
		button.layer.cornerCurve = .continuous
		button.backgroundColor = .allieWhite
		button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
		return button
	}()

	@IBAction private func authenticateApple(_ sender: Any) {
		appleAuthoizationAction?()
	}

	private(set) lazy var googleSignInButton: UIButton = {
		let button = UIButton.googleSignInButton
		button.layer.cornerRadius = 8.0
		button.layer.cornerCurve = .continuous
		let title = authorizationFlowType.googleButtonTitle
		button.setTitle(title, for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
		button.layer.borderColor = UIColor.allieSeparator.cgColor
		button.layer.borderWidth = 1.0
		return button
	}()

	private(set) lazy var bottomButton: BottomButton = {
		let button = BottomButton(frame: .zero)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
		button.setTitle(NSLocalizedString("LOG_IN", comment: "Log In"), for: .normal)
		button.setupButton()
		button.isEnabled = false
		button.backgroundColor = UIColor.allieButtons.withAlphaComponent(0.5)
		return button
	}()

	@IBAction private func authenticateGoogle(_ sender: Any) {
		GIDSignIn.sharedInstance()?.signIn()
	}

	func updateLabels() {
		googleSignInButton.setTitle(authorizationFlowType.googleButtonTitle, for: .normal)
	}
}
