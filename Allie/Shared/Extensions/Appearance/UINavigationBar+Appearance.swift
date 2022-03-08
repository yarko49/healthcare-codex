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
		let appearance = UINavigationBarAppearance()
		appearance.configureWithOpaqueBackground()
		appearance.shadowColor = .clear
		appearance.shadowImage = UIImage()
		appearance.backgroundColor = .mainBlue
		appearance.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 17.0, weight: .semibold), .foregroundColor: UIColor.allieWhite]
		navBar.tintColor = .allieWhite
		navBar.barTintColor = .mainBlue
		navBar.scrollEdgeAppearance = appearance
		navBar.standardAppearance = appearance
	}
}
