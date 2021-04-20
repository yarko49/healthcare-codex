//
//  EmailSentViewController.swift
//  Allie
//
//  Created by Waqar Malik on 4/19/21.
//

import UIKit

class EmailSentViewController: SignupBaseViewController {
	var openMailApp: Coordinable.ActionHandler?

	override func viewDidLoad() {
		super.viewDidLoad()
		view.addSubview(titleLabel)
		NSLayoutConstraint.activate([titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: titleLabel.trailingAnchor, multiplier: 2.0),
		                             titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 10.0)])
		titleLabel.text = NSLocalizedString("EMAIL_SENT", comment: "Email Sent!")
		view.addSubview(buttonStackView)
		NSLayoutConstraint.activate([buttonStackView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: buttonStackView.trailingAnchor, multiplier: 2.0),
		                             buttonStackView.topAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 8.0)])

		let imageView = UIImageView(image: UIImage(named: "illustration4-1"))
		imageView.translatesAutoresizingMaskIntoConstraints = false
		buttonStackView.alignment = .center
		buttonStackView.addArrangedSubview(imageView)

		view.addSubview(messageLabel)
		NSLayoutConstraint.activate([messageLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: messageLabel.trailingAnchor, multiplier: 2.0),
		                             messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 30.0)])

		view.addSubview(bottomButton)
		NSLayoutConstraint.activate([bottomButton.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: bottomButton.trailingAnchor, multiplier: 2.0),
		                             view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: bottomButton.bottomAnchor, multiplier: 2.0)])
		bottomButton.addTarget(self, action: #selector(openMailAppTapped(_:)), for: .touchUpInside)
		bottomButton.setTitle(NSLocalizedString("OPEN_MAIL_APP", comment: "Open Mail App"), for: .normal)
		bottomButton.isEnabled = true
		bottomButton.backgroundColor = .allieButtons
	}

	let messageLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = UIFont.systemFont(ofSize: 16.0, weight: .regular)
		label.textColor = .allieButtons
		label.textAlignment = .center
		label.text = NSLocalizedString("CHECK_MAIL", comment: "Check your email and verify")
		return label
	}()

	@IBAction func openMailAppTapped(_ sender: Any) {
		openMailApp?()
	}
}
