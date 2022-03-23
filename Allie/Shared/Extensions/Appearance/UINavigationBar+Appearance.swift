//
//  UINavigationBar+Appearance.swift
//  Allie
//
//  Created by Waqar Malik on 12/21/20.
//

import UIKit

enum NavigationBarType {
	case onboarding, main, setting

	var navigationBarBackgroundColor: UIColor {
		switch self {
		case .main:
			return .mainBlue!
		case .onboarding, .setting:
			return .white
		}
	}

	var navigationBarTintColor: UIColor {
		switch self {
		case .main:
			return .mainBlue!
		case .onboarding, .setting:
			return .white
		}
	}

	var tintColor: UIColor {
		switch self {
		case .main:
			return .allieWhite
		case .onboarding, .setting:
			return .white
		}
	}

	var fontColor: UIColor {
		switch self {
		case .main:
			return .allieWhite
		case .setting, .onboarding:
			return .black
		}
	}
}

extension UINavigationBar {
	func applyAppearnce(type: NavigationBarType) {
		let appearance = UINavigationBarAppearance()
		appearance.configureWithOpaqueBackground()
		appearance.shadowColor = .clear
		appearance.shadowImage = UIImage()
		appearance.backgroundColor = type.navigationBarBackgroundColor
		tintColor = type.tintColor
		barTintColor = type.navigationBarTintColor
		appearance.titleTextAttributes = [.font: TextStyle.silkabold24.font, .foregroundColor: type.fontColor]
		scrollEdgeAppearance = appearance
		standardAppearance = appearance
	}
}
