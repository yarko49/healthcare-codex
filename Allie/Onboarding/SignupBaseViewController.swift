//
//  SignupBaseViewController.swift
//  Allie
//
//  Created by Waqar Malik on 4/18/21.
//

import AuthenticationServices
import GoogleSignIn
import UIKit

enum ControllerViewMode {
	case onboarding
	case settings
}

class SignupBaseViewController: BaseViewController {
	var buttonHeight: CGFloat {
		view.frame.height < 700 ? 42.0 : 48.0
	}

	var buttonWidth: CGFloat {
		view.frame.width > 390 ? 375.0 : 300.0
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

	var controllerViewMode: ControllerViewMode = .onboarding

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
		if controllerViewMode == .onboarding {
			view.addSubview(titleLabel)
			NSLayoutConstraint.activate([titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2.0),
			                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: titleLabel.trailingAnchor, multiplier: 2.0),
			                             titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 4.0)])
			titleLabel.text = NSLocalizedString("PROFILE", comment: "Profile")
		} else {
			title = NSLocalizedString("PROFILE", comment: "Profile")
		}

		appleIdButton.addTarget(self, action: #selector(authenticateApple(_:)), for: .touchUpInside)
		googleSignInButton.addTarget(self, action: #selector(authenticateGoogle(_:)), for: .touchUpInside)
	}

	private(set) lazy var appleIdButton: ASAuthorizationAppleIDButton = {
		let button = ASAuthorizationAppleIDButton(type: self.authorizationFlowType.appleAuthButtonType, style: .whiteOutline)
		button.cornerRadius = 8.0
		button.layer.cornerCurve = .continuous
		button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
		button.setShadow()
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
		button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .regular)
		button.setTitleColor(.black, for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
		button.layer.borderColor = UIColor.black.cgColor
		button.layer.borderWidth = 0.8
		button.setShadow()
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
		button.setShadow()
		return button
	}()

	@IBAction private func authenticateGoogle(_ sender: Any) {
		let gidSignIn = GIDSignIn.sharedInstance()
		gidSignIn?.presentingViewController = self
		gidSignIn?.signIn()
	}

	func updateLabels() {
		googleSignInButton.setTitle(authorizationFlowType.googleButtonTitle, for: .normal)
	}
}
