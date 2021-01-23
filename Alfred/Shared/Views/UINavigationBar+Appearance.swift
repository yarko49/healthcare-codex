//
//  UINavigationBar+Appearance.swift
//  Alfred
//
//  Created by Waqar Malik on 12/21/20.
//

import UIKit

extension UINavigationBar {
	static func applyAppearance() {
		let navBar = UINavigationBar.appearance()
		navBar.isTranslucent = false
		navBar.barTintColor = .onboardingBackground
		navBar.setBackgroundImage(UIImage(), for: .default)
		navBar.shadowImage = UIImage()
		navBar.tintColor = .black
		navBar.titleTextAttributes = [NSAttributedString.Key.font: Font.sfProSemibold.of(size: 17), NSAttributedString.Key.foregroundColor: UIColor.black]
	}
}
