//
//  HealthViewController.swift
//  Allie
//
//  Created by Waqar Malik on 1/22/21.
//

import UIKit

class HealthViewController: SignupBaseViewController {
	var notNowAction: AllieActionHandler?
	var activateAction: AllieActionHandler?
	var signInAction: AllieActionHandler?

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
		                             buttonStackView.topAnchor.constraint(equalToSystemSpacingBelow: labekStackView.bottomAnchor, multiplier: 5.0)])

		[appleHealthImageView, careKitImageView].forEach { view in
			view.translatesAutoresizingMaskIntoConstraints = false
			view.clipsToBounds = false
			view.layer.shadowColor = UIColor(white: 0.0, alpha: 0.1).cgColor
			view.layer.shadowOffset = CGSize(width: 0.0, height: 10.0)
			view.layer.shadowRadius = 26.0
			view.layer.shadowOpacity = 1
		}

		view.addSubview(appleHealthImageView)
		NSLayoutConstraint.activate([appleHealthImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
		                             appleHealthImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -75)])

		view.addSubview(careKitImageView)
		NSLayoutConstraint.activate([careKitImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
		                             careKitImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 75)])

		view.addSubview(messageLabel)
		NSLayoutConstraint.activate([messageLabel.topAnchor.constraint(equalToSystemSpacingBelow: appleHealthImageView.bottomAnchor, multiplier: 5.0),
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
		label.textColor = .allieGray
		label.textAlignment = .center
		label.text = NSLocalizedString("ACTIVATION_MESSAGE", comment: "This will allow Allie to access and store\nyour Apple Health data and make it\navailable to you in the Allie app")
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
		let attrText = String.activate.attributedString(style: .regular20, foregroundColor: .allieWhite, letterSpacing: 0.38)
		button.setAttributedTitle(attrText, for: .normal)
		button.layer.cornerRadius = 8.0
		button.layer.cornerCurve = .continuous
		button.backgroundColor = .allieGray
		return button
	}()

	let notNowButton: UIButton = {
		let button = UIButton(type: .system)
		let attrText = String.notNow.attributedString(style: .regular20, foregroundColor: .allieGray, letterSpacing: 0.38)
		button.setAttributedTitle(attrText, for: .normal)
		button.layer.cornerRadius = 8.0
		button.layer.cornerCurve = .continuous
		button.layer.borderWidth = 1
		button.layer.borderColor = UIColor.allieGray.cgColor
		return button
	}()

	let appleHealthImageView: UIImageView = {
		let image = UIImage(named: "AppleHealth")
		let view = UIImageView(frame: .zero)
		view.image = image
		view.contentMode = .scaleAspectFill
		view.heightAnchor.constraint(equalToConstant: 125.0).isActive = true
		view.widthAnchor.constraint(equalToConstant: 125.0).isActive = true
		return view
	}()

	let careKitImageView: UIImageView = {
		let image = UIImage(named: "CareKit")
		let view = UIImageView(frame: .zero)
		view.image = image
		view.contentMode = .scaleAspectFill
		view.heightAnchor.constraint(equalToConstant: 125.0).isActive = true
		view.widthAnchor.constraint(equalToConstant: 125.0).isActive = true
		return view
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
