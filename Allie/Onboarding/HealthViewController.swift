//
//  HealthViewController.swift
//  Allie
//
//  Created by Waqar Malik on 1/22/21.
//

import UIKit

class HealthViewController: SignupBaseViewController {
	var notNowAction: Coordinable.ActionHandler?
	var activateAction: Coordinable.ActionHandler?
	var signInAction: Coordinable.ActionHandler?

	var screenFlowType: ScreenFlowType = .welcome {
		didSet {
			configureView()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		navigationController?.setNavigationBarHidden(false, animated: false)
		view.backgroundColor = .allieWhite

		titleLabel.text = NSLocalizedString("ACTIVATE_APPLE_HEALTH", comment: "Activate\nApple Health")
		titleLabel.numberOfLines = 2
		view.addSubview(buttonStackView)
		NSLayoutConstraint.activate([buttonStackView.widthAnchor.constraint(equalToConstant: buttonWidth),
		                             buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
		                             buttonStackView.topAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 5.0)])

		let imageView = UIImageView(image: UIImage(named: "illustration8"))
		imageView.translatesAutoresizingMaskIntoConstraints = false
		buttonStackView.alignment = .center
		buttonStackView.addArrangedSubview(imageView)

		view.addSubview(messageLabel)
		NSLayoutConstraint.activate([messageLabel.topAnchor.constraint(equalToSystemSpacingBelow: buttonStackView.bottomAnchor, multiplier: 2.0),
		                             messageLabel.widthAnchor.constraint(equalToConstant: buttonWidth),
		                             messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)])

		activationButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(activationButtonsStackView)
		NSLayoutConstraint.activate([activationButtonsStackView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: activationButtonsStackView.trailingAnchor, multiplier: 2.0),
		                             view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: activationButtonsStackView.bottomAnchor, multiplier: 2.0)])

		notNowButton.translatesAutoresizingMaskIntoConstraints = false
		activationButtonsStackView.addArrangedSubview(notNowButton)
		notNowButton.addTarget(self, action: #selector(notNowTapped(_:)), for: .touchUpInside)
		activateButton.translatesAutoresizingMaskIntoConstraints = false
		activationButtonsStackView.addArrangedSubview(activateButton)
		activateButton.addTarget(self, action: #selector(activateTapped(_:)), for: .touchUpInside)
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

	let messageLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = UIFont.systemFont(ofSize: 20.0, weight: .regular)
		label.textColor = .allieButtons
		label.textAlignment = .center
		label.text = NSLocalizedString("ACTIVATION_MESSAGE", comment: "This will allow Allie to compare different measurements to give you the right type of assistance.")
		label.numberOfLines = 0
		return label
	}()

	let activationButtonsStackView: UIStackView = {
		let view = UIStackView(frame: .zero)
		view.axis = .horizontal
		view.alignment = .center
		view.distribution = .fillEqually
		view.spacing = 16.0
		return view
	}()

	let activateButton: UIButton = {
		let button = UIButton(type: .system)
		let attrText = String.activate.with(style: .regular20, andColor: .allieWhite, andLetterSpacing: 0.38)
		button.setAttributedTitle(attrText, for: .normal)
		button.layer.cornerRadius = 8.0
		button.layer.cornerCurve = .continuous
		button.backgroundColor = .allieButtons
		return button
	}()

	let notNowButton: UIButton = {
		let button = UIButton(type: .system)
		let attrText = String.notNow.with(style: .regular20, andColor: .allieButtons, andLetterSpacing: 0.38)
		button.setAttributedTitle(attrText, for: .normal)
		button.layer.cornerRadius = 8.0
		button.layer.cornerCurve = .continuous
		button.layer.borderWidth = 1
		button.layer.borderColor = UIColor.allieButtons.cgColor
		return button
	}()

	private func configureView() {
		title = screenFlowType.viewTitle
		activationButtonsStackView.isHidden = screenFlowType != .healthKit
	}

	@IBAction func notNowTapped(_ sender: Any) {
		notNowAction?()
	}

	@IBAction func activateTapped(_ sender: Any) {
		activateAction?()
	}
}
