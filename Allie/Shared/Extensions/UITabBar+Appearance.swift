//
//  UITabbar+Appearance.swift
//  Allie
//
//  Created by Waqar Malik on 4/14/21.
//

import UIKit

extension UITabBar {
	override class func applyAppearance() {
		let tabbar = UITabBar.appearance()
		tabbar.tintColor = .allieBlack
		tabbar.backgroundColor = .allieWhite
		tabbar.backgroundImage = UIImage()
		tabbar.shadowImage = UIImage()
	}
}
