//
//  ConnectProviderViewController.swift
//  Allie
//
//  Created by Waqar Malik on 6/24/21.
//

import UIKit

class ConnectProviderViewController: SignupBaseViewController {
	var showProviderList: AllieVoidCompletion?

	let messageLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .center
		label.attributedText = NSLocalizedString("CONNECT_PROVIDER.title", comment: "Connect to your healthcare provider to get the full benefits of Allie").attributedString(style: .silkaregular17, foregroundColor: .black)
		label.numberOfLines = 0
		return label
	}()

	let centerLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .center
		label.attributedText = NSLocalizedString("HEALTHCARE_PROVIDER", comment: "Healthcare Provider").attributedString(style: .silkabold24, foregroundColor: .mainBlue)
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
		imageView.image = UIImage(named: "img-connect")
		return imageView
	}()

	let activateButton: UIButton = {
		let button = UIButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		let attrText = NSLocalizedString("CONNECT", comment: "Connect").attributedString(style: .silkabold16, foregroundColor: .allieWhite)
		button.setAttributedTitle(attrText, for: .normal)
		button.layer.cornerRadius = 8.0
		button.layer.cornerCurve = .continuous
		button.backgroundColor = .black
		return button
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .allieWhite
		titleLabel.isHidden = true
		navigationController?.setNavigationBarHidden(false, animated: false)

		title = NSLocalizedString("CONNECT", comment: "Connect")

		activateButton.addTarget(self, action: #selector(showProviderSelector(_:)), for: .touchUpInside)

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
	}

	@objc func showProviderSelector(_ sender: Any?) {
		showProviderList?()
	}
}
