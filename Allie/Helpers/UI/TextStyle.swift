//
//  TextStyle.swift
//  Allie
//

import UIKit

enum TextStyle {
	case regular12
	case regular13
	case regular15
	case regular16
	case regular17
	case regular20
	case regular24
	case regular26
	case regular28
	case medium13
	case medium17
	case semibold17
	case semibold20
	case semibold26
	case bold28
	case bold16
	case bold17
	case bold20
	case bold24
	case silkaregular12
	case silkaregular13
	case silkaregular15
	case silkaregular16
	case silkaregular17
	case silkaregular20
	case silkaregular24
	case silkaregular26
	case silkaregular28
	case silkamedium13
	case silkamedium17
	case silkasemibold14
	case silkasemibold17
	case silkasemibold20
	case silkasemibold24
	case silkasemibold26
	case silkabold28
	case silkabold16
	case silkabold17
	case silkabold20
	case silkabold24
	case silkabold36
	case silkabold14

	var font: UIFont {
		switch self {
		case .regular12: return UIFont.systemFont(ofSize: 12.0, weight: .regular)
		case .regular13: return UIFont.systemFont(ofSize: 13.0, weight: .regular)
		case .regular15: return UIFont.systemFont(ofSize: 15.0, weight: .regular)
		case .regular16: return UIFont.systemFont(ofSize: 16.0, weight: .regular)
		case .regular17: return UIFont.systemFont(ofSize: 17.0, weight: .regular)
		case .regular20: return UIFont.systemFont(ofSize: 20.0, weight: .regular)
		case .regular24: return UIFont.systemFont(ofSize: 24.0, weight: .regular)
		case .regular26: return UIFont.systemFont(ofSize: 26.0, weight: .regular)
		case .regular28: return UIFont.systemFont(ofSize: 28.0, weight: .regular)
		case .medium13: return UIFont.systemFont(ofSize: 13.0, weight: .medium)
		case .medium17: return UIFont.systemFont(ofSize: 17.0, weight: .medium)
		case .semibold17: return UIFont.systemFont(ofSize: 17.0, weight: .semibold)
		case .semibold20: return UIFont.systemFont(ofSize: 20.0, weight: .semibold)
		case .semibold26: return UIFont.systemFont(ofSize: 26.0, weight: .semibold)
		case .bold16: return UIFont.systemFont(ofSize: 16.0, weight: .bold)
		case .bold17: return UIFont.systemFont(ofSize: 17.0, weight: .bold)
		case .bold20: return UIFont.systemFont(ofSize: 20.0, weight: .bold)
		case .bold24: return UIFont.systemFont(ofSize: 24.0, weight: .bold)
		case .bold28: return UIFont.systemFont(ofSize: 28.0, weight: .bold)
		case .silkaregular12: return UIFont(name: "Silka-Regular", size: 12.0)!
		case .silkaregular13: return UIFont(name: "Silka-Regular", size: 13.0)!
		case .silkaregular15: return UIFont(name: "Silka-Regular", size: 15.0)!
		case .silkaregular16: return UIFont(name: "Silka-Regular", size: 16.0)!
		case .silkaregular17: return UIFont(name: "Silka-Regular", size: 17.0)!
		case .silkaregular20: return UIFont(name: "Silka-Regular", size: 20.0)!
		case .silkaregular24: return UIFont(name: "Silka-Regular", size: 24.0)!
		case .silkaregular26: return UIFont(name: "Silka-Regular", size: 26.0)!
		case .silkaregular28: return UIFont(name: "Silka-Regular", size: 28.0)!
		case .silkamedium13: return UIFont(name: "Silka-Medium", size: 13.0)!
		case .silkamedium17: return UIFont(name: "Silka-Medium", size: 17.0)!
		case .silkasemibold14: return UIFont(name: "Silka-SemiBold", size: 14.0)!
		case .silkasemibold17: return UIFont(name: "Silka-SemiBold", size: 17.0)!
		case .silkasemibold20: return UIFont(name: "Silka-SemiBold", size: 20.0)!
		case .silkasemibold24: return UIFont(name: "Silka-SemiBold", size: 24.0)!
		case .silkasemibold26: return UIFont(name: "Silka-SemiBold", size: 26.0)!
		case .silkabold28: return UIFont(name: "Silka-Bold", size: 28.0)!
		case .silkabold16: return UIFont(name: "Silka-Bold", size: 16.0)!
		case .silkabold17: return UIFont(name: "Silka-Bold", size: 17.0)!
		case .silkabold20: return UIFont(name: "Silka-Bold", size: 20.0)!
		case .silkabold24: return UIFont(name: "Silka-Bold", size: 24.0)!
		case .silkabold36: return UIFont(name: "Silka-Bold", size: 36.0)!
		case .silkabold14: return UIFont(name: "Silka-Bold", size: 14.0)!
		}
	}

	static func combineAttributedStrings(string1: NSAttributedString, string2: NSAttributedString) -> NSAttributedString {
		let ss = NSMutableAttributedString(attributedString: string1)
		ss.append(string2)
		return ss
	}
}

extension String {
	func attributedString(style: TextStyle, foregroundColor: UIColor? = nil, letterSpacing: CGFloat? = nil) -> NSAttributedString {
		var attributes: [NSAttributedString.Key: Any] = [.font: style.font]
		if let color = foregroundColor {
			attributes[.foregroundColor] = color
		}
		if let kern = letterSpacing {
			attributes[.kern] = NSNumber(value: Double(kern))
		}
		return NSAttributedString(string: self, attributes: attributes)
	}
}

extension NSAttributedString {
	func byAdding(style: TextStyle, foregroundColor: UIColor? = nil, letterSpacing: CGFloat? = nil) -> NSAttributedString {
		guard let mutableSelf = mutableCopy() as? NSMutableAttributedString else {
			return NSAttributedString()
		}
		let fullRange = NSRange(location: 0, length: mutableSelf.string.utf16.count)
		var newAttributes: [NSAttributedString.Key: Any] = [.font: style.font]
		if let color = foregroundColor {
			newAttributes[.foregroundColor] = color
		}
		if let kern = letterSpacing {
			newAttributes[.kern] = NSNumber(value: Double(kern))
		}
		mutableSelf.addAttributes(newAttributes, range: fullRange)
		return mutableSelf
	}
}
