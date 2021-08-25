//
//  UIButton+Custom.swift
//  Allie
//
//  Created by Waqar Malik on 8/23/21.
//

import UIKit

extension UIButton {
	class var grayButton: UIButton {
		let button = UIButton(type: .system)
		button.setTitleColor(.allieWhite, for: .normal)
		button.backgroundColor = .allieGray
		button.layer.cornerRadius = 8.0
		button.layer.cornerCurve = .continuous
		return button
	}
}
