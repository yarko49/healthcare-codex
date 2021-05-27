//
//  UINavigationBar+Appearance.swift
//  Allie
//
//  Created by Waqar Malik on 12/21/20.
//

import UIKit

extension UINavigationBar {
	override class func applyAppearance() {
		let navBar = UINavigationBar.appearance()
		navBar.isTranslucent = false
		navBar.barTintColor = .allieWhite
		navBar.setBackgroundImage(UIImage(), for: .default)
		navBar.shadowImage = UIImage()
		navBar.tintColor = .allieBlack
		navBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.0, weight: .semibold), NSAttributedString.Key.foregroundColor: UIColor.allieBlack]
	}
}
