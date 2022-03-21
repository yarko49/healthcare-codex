//
//  HealthViewController.swift
//  Allie
//
//  Created by Waqar Malik on 1/22/21.
//

import UIKit

class HealthViewController: SignupBaseViewController {
	var activateAction: AllieActionHandler?
	var signInAction: AllieActionHandler?

	let messageLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .center
		label.attributedText = NSLocalizedString("ACTIVATION_MESSAGE", comment: "This will allow Allie to access and store your Apple Health data and make it available to you in the Allie app").attributedString(style: .silkaregular17, foregroundColor: .black)
		label.numberOfLines = 0
		return label
	}()

	let centerLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .center
		label.attributedText = NSLocalizedString("APPLE_HEALTH", comment: "Apple Health").attributedString(style: .silkabold24, foregroundColor: .mainBlue)
		label.numberOfLines = 0
		return label
	}()

	let labelStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.alignment = .center
		stackView.distribution = .fill
		stackView.spacing = 24
		return stackView
	}()

	let imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFit
		imageView.image = UIImage(named: "img-activate")
		return imageView
	}()

	let activateButton: UIButton = {
		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		let attrText = String.activate.attributedString(style: .silkabold16, foregroundColor: .allieWhite)
		button.setAttributedTitle(attrText, for: .normal)
		button.layer.cornerRadius = 8.0
		button.layer.cornerCurve = .continuous
		button.backgroundColor = .black
		return button
	}()

	var screenFlowType: ScreenFlowType = .welcome {
		didSet {
			configureView()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		navigationController?.setNavigationBarHidden(false, animated: false)
		view.backgroundColor = .allieWhite

		title = String.activate

		titleLabel.isHidden = true

		[imageView, labelStackView, activateButton].forEach { view.addSubview($0) }
		[centerLabel, messageLabel].forEach { labelStackView.addArrangedSubview($0) }

		NSLayoutConstraint.activate([imageView.topAnchor.constraint(equalTo: view.safeTopAnchor, constant: 20),
		                             imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)])
		NSLayoutConstraint.activate([labelStackView.topAnchor.constraint(equalTo: imageView.bottomAnchor),
		                             labelStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
		                             labelStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50)])
		NSLayoutConstraint.activate([activateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
		                             activateButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
		                             activateButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24),
		                             activateButton.heightAnchor.constraint(equalToConstant: 48)])

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

	private func configureView() {
		activateButton.isHidden = screenFlowType != .healthKit
	}

	@IBAction func activateTapped(_ sender: Any) {
		activateAction?()
	}
}
