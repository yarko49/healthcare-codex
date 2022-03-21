//
//  EmailSentViewController.swift
//  Allie
//
//  Created by Waqar Malik on 4/19/21.
//

import UIKit

class EmailSentViewController: SignupBaseViewController {
	var openMailApp: AllieActionHandler?

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .mainBlue
		titleLabel.attributedText = NSLocalizedString("EMAIL_SENT", comment: "Email Sent!").attributedString(style: .silkabold24, foregroundColor: .white)
		subtitleLabel.attributedText = NSLocalizedString("CHECK_MAIL", comment: "Check your email and use the verify link").attributedString(style: .silkamedium20, foregroundColor: .white)
		subtitleLabel.isHidden = false
		view.addSubview(buttonStackView)
		NSLayoutConstraint.activate([buttonStackView.widthAnchor.constraint(equalToConstant: buttonWidth),
		                             buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
		                             buttonStackView.topAnchor.constraint(equalToSystemSpacingBelow: labekStackView.bottomAnchor, multiplier: 8.0),
		                             buttonStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])

		let imageView = UIImageView(image: UIImage(named: "img-email-sent"))
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		buttonStackView.alignment = .center
		buttonStackView.addArrangedSubview(imageView)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
		navigationController?.setNavigationBarHidden(true, animated: animated)
	}

	@IBAction func openMailAppTapped(_ sender: Any) {
		openMailApp?()
	}
}
