//  GoogleSignInButton.swift
//  Allie

import UIKit

extension UIButton {
	static var googleSignInButton: UIButton {
		let button = UIButton(type: .custom)
		button.setImage(UIImage(named: "icon-logo-google"), for: .normal)
		button.setTitleColor(.google ?? .black, for: .normal)
		button.titleLabel?.font = UIFont.systemFont(ofSize: 20.0, weight: .semibold)
		button.titleEdgeInsets.left = 14
		button.contentEdgeInsets.top = 12
		button.contentEdgeInsets.bottom = 12
		button.layer.cornerCurve = .continuous
		button.layer.borderWidth = 1.0
		button.layer.borderColor = UIColor.grey.cgColor
		return button
	}

	static func googleSignInButton(title: String) -> UIButton {
		let button = googleSignInButton
		button.setTitle(title, for: .normal)
		return button
	}
}
