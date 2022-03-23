//
//  SignupBaseViewController.swift
//  Allie
//
//  Created by Waqar Malik on 4/18/21.
//

import AuthenticationServices
import Combine
import SwiftUI
import UIKit

enum ControllerViewMode {
	case onboarding
	case settings
}

class SignupBaseViewController: UIViewController {
	var cancellables: Set<AnyCancellable> = []

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

	var authorizationFlowType: AuthorizationFlowType = .signIn {
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
		view.backgroundColor = .white
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

		setupNavigationView()
	}

	private(set) lazy var appleIdButton: UIButton = {
		let button = UIButton.googleSignInButton
		button.backgroundColor = .white
		button.layer.cornerRadius = 8.0
		button.layer.cornerCurve = .continuous
		let title = authorizationFlowType.appleButtonTitle
		button.setTitle(title, for: .normal)
		button.titleLabel?.font = TextStyle.silkasemibold16.font
		button.setTitleColor(.black, for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
		button.layer.borderColor = UIColor.black.cgColor
		button.layer.borderWidth = 0
		button.setImage(UIImage(systemName: "applelogo"), for: .normal)
		button.tintColor = .black
		button.setShadow(shadowColor: .mainShadow, opacity: 0.7)
		return button
	}()

	@IBAction private func authenticateApple(_ sender: Any) {
		appleAuthoizationAction?()
	}

	private(set) lazy var googleSignInButton: UIButton = {
		let button = UIButton.googleSignInButton
		button.backgroundColor = .white
		button.layer.cornerRadius = 8.0
		button.layer.cornerCurve = .continuous
		let title = authorizationFlowType.googleButtonTitle
		button.setTitle(title, for: .normal)
		button.titleLabel?.font = TextStyle.silkasemibold16.font
		button.setTitleColor(.black, for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
		button.layer.borderColor = UIColor.black.cgColor
		button.layer.borderWidth = 0
		button.setShadow(shadowColor: .mainShadow, opacity: 0.7)
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
		appleIdButton.setTitle(authorizationFlowType.appleButtonTitle, for: .normal)
	}

	private func setupNavigationView() {
		navigationController?.navigationBar.applyAppearnce(type: .onboarding)
		let backButton = UIButton()
		backButton.frame = CGRect(x: 0, y: -6, width: 44, height: 44)
		backButton.backgroundColor = .mainBlue
		backButton.layer.cornerRadius = 22.0
		backButton.setImage(UIImage(systemName: "arrow.left"), for: .normal)
		backButton.tintColor = .white
		backButton.addTarget(self, action: #selector(onClickBackButton), for: .touchUpInside)

		navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
	}

	@objc func onClickBackButton() {
		navigationController?.popViewController()
	}
}
