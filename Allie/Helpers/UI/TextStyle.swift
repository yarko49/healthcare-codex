//
//  TextStyle.swift
//  Allie
//

import BonMot
import UIKit

struct TextStyle {
	enum Style {
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

		func stringStyle() -> StringStyle {
			switch self {
			case .regular12: return regular12Style
			case .regular13: return regular13Style
			case .regular15: return regular15Style
			case .regular16: return regular16Style
			case .regular17: return regular17Style
			case .regular20: return regular20Style
			case .regular24: return regular24Style
			case .regular26: return regular26Style
			case .regular28: return regular28Style
			case .medium13: return medium13Style
			case .medium17: return medium17Style
			case .semibold17: return semibold17Style
			case .semibold20: return semibold20Style
			case .bold28: return bold28Style
			case .semibold26: return semibold26Style
			case .bold16: return bold16Style
			case .bold17: return bold17Style
			case .bold20: return bold20Style
			case .bold24: return bold24Style
			}
		}
	}

	static let regular12Style = StringStyle(.font(UIFont.systemFont(ofSize: 12.0, weight: .regular)))
	static let regular13Style = StringStyle(.font(UIFont.systemFont(ofSize: 13.0, weight: .regular)))
	static let regular15Style = StringStyle(.font(UIFont.systemFont(ofSize: 15.0, weight: .regular)))
	static let regular16Style = StringStyle(.font(UIFont.systemFont(ofSize: 16.0, weight: .regular)))
	static let regular17Style = StringStyle(.font(UIFont.systemFont(ofSize: 17.0, weight: .regular)))
	static let regular20Style = StringStyle(.font(UIFont.systemFont(ofSize: 20.0, weight: .regular)))
	static let regular24Style = StringStyle(.font(UIFont.systemFont(ofSize: 24.0, weight: .regular)))
	static let regular26Style = StringStyle(.font(UIFont.systemFont(ofSize: 26.0, weight: .regular)))
	static let regular28Style = StringStyle(.font(UIFont.systemFont(ofSize: 28.0, weight: .regular)))
	static let medium13Style = StringStyle(.font(UIFont.systemFont(ofSize: 13.0, weight: .medium)))
	static let medium17Style = StringStyle(.font(UIFont.systemFont(ofSize: 17.0, weight: .medium)))

	static let semibold17Style = StringStyle(.font(UIFont.systemFont(ofSize: 17.0, weight: .semibold)))
	static let semibold20Style = StringStyle(.font(UIFont.systemFont(ofSize: 20.0, weight: .semibold)))
	static let semibold26Style = StringStyle(.font(UIFont.systemFont(ofSize: 26.0, weight: .semibold)))
	static let bold28Style = StringStyle(.font(UIFont.systemFont(ofSize: 28.0, weight: .bold)))
	static let bold16Style = StringStyle(.font(UIFont.systemFont(ofSize: 16.0, weight: .bold)))
	static let bold17Style = StringStyle(.font(UIFont.systemFont(ofSize: 17.0, weight: .bold)))
	static let bold20Style = StringStyle(.font(UIFont.systemFont(ofSize: 20.0, weight: .bold)))
	static let bold24Style = StringStyle(.font(UIFont.systemFont(ofSize: 24.0, weight: .bold)))

	static func combineAttributedStrings(string1: NSAttributedString, string2: NSAttributedString) -> NSAttributedString {
		let ss = NSMutableAttributedString(attributedString: string1)
		ss.append(string2)
		return ss
	}
}

extension String {
	func with(_ style: TextStyle.Style) -> NSAttributedString {
		styled(with: style.stringStyle())
	}

	func with(style: TextStyle.Style, andColor: UIColor) -> NSAttributedString {
		styled(with: style.stringStyle(), .color(andColor))
	}

	func with(style: TextStyle.Style, andColor: UIColor, andLetterSpacing: CGFloat) -> NSAttributedString {
		styled(with: style.stringStyle(), .color(andColor), .tracking(.point(andLetterSpacing)))
	}
}

extension NSAttributedString {
	func with(_ style: TextStyle.Style) -> NSAttributedString {
		styled(with: style.stringStyle())
	}

	func with(style: TextStyle.Style, andColor: UIColor) -> NSAttributedString {
		styled(with: style.stringStyle(), .color(andColor))
	}

	func with(style: TextStyle.Style, andColor: UIColor, andLetterSpacing: CGFloat) -> NSAttributedString {
		styled(with: style.stringStyle(), .color(andColor), .tracking(.point(andLetterSpacing)))
	}
}
