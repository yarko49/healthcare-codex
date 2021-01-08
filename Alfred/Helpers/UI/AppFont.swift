//
//  AppFont.swift
//  Alfred
//

import UIKit

enum Font: String {
	case sfProMedium = "SFProText-Medium"
	case sfProLight = "SFProText-Light"
	case sfProRegular = "SFProText-Regular"
	case sfProSemiboldItalic = "SFProText-SemiboldItalic"
	case sfProHeavy = "SFProText-Heavy"
	case sfProRegularItalic = "SFProText-RegularItalic"
	case sfProBold = "SFProText-Bold"
	case sfProMediumItalic = "SFProText-MediumItalic"
	case sfProBoldItalic = "SFProText-BoldItalic"
	case sfProSemibold = "SFProText-Semibold"
	case sfProLightItalic = "SFProText-LightItalic"
	case sfProHeavyItalic = "SFProText-HeavyItalic"
	case sfProThin = "SFProText-Thin"

	func of(size: CGFloat) -> UIFont {
		guard let font = UIFont(name: rawValue, size: size) else {
			fatalError("\(rawValue) font is not installed, make sure it added in Info.plist and logged with Font.logAllAvailableFonts()")
		}
		return font
	}

	static func logAllAvailableFonts() {
		for family in UIFont.familyNames {
			ALog.info("\(family)")
			for name in UIFont.fontNames(forFamilyName: family) {
				ALog.info("\t\(name)")
			}
		}
	}
}
