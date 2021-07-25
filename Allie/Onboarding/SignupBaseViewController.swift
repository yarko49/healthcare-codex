//
//  SignupBaseViewController.swift
//  Allie
//
//  Created by Waqar Malik on 4/18/21.
//

import AuthenticationServices
import UIKit

enum ControllerViewMode {
	case onboarding
	case settings
}

class SignupBaseViewController: BaseViewController {
	deinit {
		cancellables.forEach { cancellable in
			cancellable.cancel()
		}
		cancellables.removeAll()
	}

	var buttonHeight: CGFloat {
		view.frame.height < 700 ? 42.0 : 48.0
	}

	var buttonWidth: CGFloat {
		view.frame.width > 390 ? 375.0 : 300.0
	}

	var authorizeWithEmail: ((_ email: String, _ authorizationFlowType: AuthorizationFlowType) -> Void)?
	var appleAuthoizationAction: AllieActionHandler?
	var googleAuthorizationAction: AllieActionHandler?
	var emailAuthorizationAction: ((AuthorizationFlowType) -> Void)?
	var authorizationFlowChangedAction: ((AuthorizationFlowType) -> Void)?

	var authorizationFlowType: AuthorizationFlowType = .signUp {
		didSet {
			updateLabels()
		}
	}

	var controllerViewMode: ControllerViewMode = .onboarding

	let labekStackView: UIStackView = {
		let view = UIStackView(frame: .zero)
		view.axis = .vertical
		view.spacing = 32.0
		view.distribution = .fill
		view.alignment = .fill
		return view
	}()

	private(set) lazy var titleLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = .allieBlack
		label.textAlignment = .center
		label.text = NSLocalizedString("LOGIN", comment: "Login")
		label.font = UIFont.systemFont(ofSize: 26.0, weight: .bold)
		return label
	}()

	private(set) lazy var subtitleLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = .allieBlack
		label.textAlignment = .center
		label.text = nil
		label.numberOfLines = 0
		label.font = UIFont.systemFont(ofSize: 20.0, weight: .regular)
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
			[labekStackView, titleLabel, subtitleLabel].forEach { view in
				view.translatesAutoresizingMaskIntoConstraints = false
			}
			view.addSubview(labekStackView)
			NSLayoutConstraint.activate([labekStackView.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 4.0),
			                             labekStackView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2.0),
			                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: labekStackView.trailingAnchor, multiplier: 2.0)])
			labekStackView.addArrangedSubview(titleLabel)
			labekStackView.addArrangedSubview(subtitleLabel)
			subtitleLabel.isHidden = true
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
		let button = BottomButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
		button.setTitle(NSLocalizedString("LOG_IN", comment: "Log In"), for: .normal)
		button.setupButton()
		button.isEnabled = false
		button.backgroundColor = UIColor.allieGray.withAlphaComponent(0.5)
		button.setShadow()
		return button
	}()

	@IBAction private func authenticateGoogle(_ sender: Any) {
		googleAuthorizationAction?()
	}

	func updateLabels() {
		googleSignInButton.setTitle(authorizationFlowType.googleButtonTitle, for: .normal)
	}
}
