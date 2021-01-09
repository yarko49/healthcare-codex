//
//  emailSignInButton.swift
//  Alfred

import Foundation
import UIKit

extension UIButton {
	static var emailSignInButton: UIButton {
		let button = UIButton(type: .custom)
		button.titleEdgeInsets.left = 14
		button.contentEdgeInsets.top = 12
		button.contentEdgeInsets.bottom = 12
		button.layer.cornerRadius = 20.0
		button.layer.cornerCurve = .continuous
		button.layer.borderWidth = 1.0
		button.layer.borderColor = UIColor.grey.cgColor
		button.setTitleColor(.grey, for: .normal)
		button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title3)
		return button
	}

	static func emailSignInButton(title: String, image: UIImage? = nil) -> UIButton {
		let button = emailSignInButton
		button.setTitle(title, for: .normal)
		if let image = image {
			button.setImage(image, for: .normal)
		}
		return button
	}
}
