//
//  HealthViewController.swift
//  Allie
//
//  Created by Waqar Malik on 1/22/21.
//

import UIKit

class HealthViewController: BaseViewController {
	var nextButtonAction: Coordinable.ActionHandler?
	var notNowAction: Coordinable.ActionHandler?
	var activateAction: Coordinable.ActionHandler?
	var signInAction: Coordinable.ActionHandler?

	var screenFlowType: ScreenFlowType = .welcome {
		didSet {
			configureView()
		}
	}

	var authorizationFlowType: AuthorizationFlowType = .signUp

	override func viewDidLoad() {
		super.viewDidLoad()
		navigationController?.setNavigationBarHidden(false, animated: false)
		view.backgroundColor = .onboardingBackground
		illustrationView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(illustrationView)
		NSLayoutConstraint.activate([illustrationView.heightAnchor.constraint(equalToConstant: 450.0),
		                             illustrationView.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 10.0),
		                             illustrationView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 0.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: illustrationView.trailingAnchor, multiplier: 0.0)])

		bottomView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(bottomView)
		NSLayoutConstraint.activate([bottomView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 0.0),
		                             view.trailingAnchor.constraint(equalToSystemSpacingAfter: bottomView.trailingAnchor, multiplier: 0.0),
		                             view.bottomAnchor.constraint(equalToSystemSpacingBelow: bottomView.bottomAnchor, multiplier: 0.0),
		                             bottomView.heightAnchor.constraint(equalToConstant: 60.0)])

		nextButton.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(nextButton)
		NSLayoutConstraint.activate([nextButton.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 0.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: nextButton.trailingAnchor, multiplier: 0.0),
		                             view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: nextButton.bottomAnchor, multiplier: 0.0),
		                             nextButton.heightAnchor.constraint(equalToConstant: 60)])
		nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)

		buttonStackView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(buttonStackView)
		NSLayoutConstraint.activate([buttonStackView.widthAnchor.constraint(equalToConstant: 334), buttonStackView.heightAnchor.constraint(equalToConstant: 44.0),
		                             buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
		                             view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: buttonStackView.bottomAnchor, multiplier: 3.75)])
		leftButton.translatesAutoresizingMaskIntoConstraints = false
		buttonStackView.addArrangedSubview(leftButton)
		leftButton.addTarget(self, action: #selector(notNowTapped(_:)), for: .touchUpInside)
		rightButton.translatesAutoresizingMaskIntoConstraints = false
		buttonStackView.addArrangedSubview(rightButton)
		rightButton.addTarget(self, action: #selector(activateTapped(_:)), for: .touchUpInside)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		if screenFlowType == .welcome {
			signInAction?()
		}
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		AnalyticsManager.send(event: .pageView, properties: [.name: "HealthView", .screenFlowType: screenFlowType])
	}

	let illustrationView: IllustrationView = {
		let view = IllustrationView(frame: .zero)
		view.imageView.image = nil
		view.titleLabel.text = ""
		view.titleLabel.font = UIFont.systemFont(ofSize: 20.0, weight: .bold)
		view.subtitleLabel.font = UIFont.systemFont(ofSize: 17.0, weight: .regular)
		view.subtitleLabel.textColor = .grey
		view.subtitleLabel.numberOfLines = 0
		return view
	}()

	let nextButton: UIButton = {
		let button = UIButton(type: .system)
		return button
	}()

	let bottomView: UIView = {
		let view = UIView(frame: .zero)
		view.backgroundColor = .purple
		return view
	}()

	let buttonStackView: UIStackView = {
		let view = UIStackView(frame: .zero)
		view.axis = .horizontal
		view.alignment = .center
		view.distribution = .fillEqually
		view.spacing = 34.0
		return view
	}()

	let rightButton: UIButton = {
		let button = UIButton(type: .system)
		let attrText = Str.activate.with(style: .regular20, andColor: .white, andLetterSpacing: 0.38)
		button.setAttributedTitle(attrText, for: .normal)
		button.layer.cornerRadius = 20.0
		button.layer.cornerCurve = .continuous
		button.backgroundColor = .grey
		return button
	}()

	let leftButton: UIButton = {
		let button = UIButton(type: .system)
		let attrText = Str.notNow.with(style: .regular20, andColor: .black, andLetterSpacing: 0.38)
		button.setAttributedTitle(attrText, for: .normal)
		button.layer.cornerRadius = 20.0
		button.layer.cornerCurve = .continuous
		button.layer.borderWidth = 1
		button.layer.borderColor = UIColor.grey.cgColor
		return button
	}()

	private func configureView() {
		title = screenFlowType.viewTitle
		illustrationView.titleLabel.text = screenFlowType.title
		illustrationView.subtitleLabel.text = screenFlowType.subtitle
		illustrationView.imageView.image = screenFlowType.image
		var buttonText = screenFlowType.buttonTitle
		var buttonBackgroundColor: UIColor? = screenFlowType != .activate ? .next : .grey
		if authorizationFlowType == .signIn, screenFlowType == .welcomeSuccess {
			buttonText = ScreenFlowType.activate.buttonTitle
			buttonBackgroundColor = .grey
		}
		nextButton.setAttributedTitle(buttonText.with(style: .regular17, andColor: .white, andLetterSpacing: 5), for: .normal)
		nextButton.backgroundColor = buttonBackgroundColor
		bottomView.backgroundColor = nextButton.backgroundColor
		buttonStackView.isHidden = screenFlowType != .healthKit
		nextButton.isHidden = screenFlowType == .healthKit
		bottomView.isHidden = screenFlowType == .healthKit
	}

	@IBAction func notNowTapped(_ sender: Any) {
		notNowAction?()
	}

	@IBAction func activateTapped(_ sender: Any) {
		activateAction?()
	}

	@objc func nextButtonTapped() {
		nextButtonAction?()
	}
}
