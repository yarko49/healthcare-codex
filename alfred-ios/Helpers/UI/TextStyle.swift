//
//  TextStyle.swift
//  alfred-ios
//

import Foundation
import BonMot

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
            case .bold16: return bold16Style
            case .bold17: return bold17Style
            case .bold20: return bold20Style
            case .bold24: return bold24Style
            }
        }
    }

    static let regular12Style = StringStyle(.font(Font.sfProRegular.of(size: 12)))
    static let regular13Style = StringStyle(.font(Font.sfProRegular.of(size: 13)))
    static let regular15Style = StringStyle(.font(Font.sfProRegular.of(size: 15)))
    static let regular16Style = StringStyle(.font(Font.sfProRegular.of(size: 16)))
    static let regular17Style = StringStyle(.font(Font.sfProRegular.of(size: 17)))
    static let regular20Style = StringStyle(.font(Font.sfProRegular.of(size: 20)))
    static let regular24Style = StringStyle(.font(Font.sfProRegular.of(size: 24)))
    static let regular26Style = StringStyle(.font(Font.sfProRegular.of(size: 26)))
    static let regular28Style = StringStyle(.font(Font.sfProRegular.of(size: 28)))
    static let medium13Style = StringStyle(.font(Font.sfProMedium.of(size: 13)))
    static let medium17Style = StringStyle(.font(Font.sfProMedium.of(size: 17)))

    static let semibold17Style = StringStyle(.font(Font.sfProSemibold.of(size: 17)))
    static let semibold20Style = StringStyle(.font(Font.sfProSemibold.of(size: 20)))
    static let bold28Style = StringStyle(.font(Font.sfProBold.of(size: 28)))
    static let bold16Style = StringStyle(.font(Font.sfProBold.of(size: 16)))
    static let bold17Style = StringStyle(.font(Font.sfProBold.of(size: 17)))
    static let bold20Style = StringStyle(.font(Font.sfProBold.of(size: 20)))
    static let bold24Style = StringStyle(.font(Font.sfProBold.of(size: 24)))
    
    static func combineAttributedStrings(string1: NSAttributedString, string2: NSAttributedString) -> NSAttributedString {
        let ss = NSMutableAttributedString(attributedString: string1)
        ss.append(string2)
        return ss
    }
}

extension String {
    func with(_ style: TextStyle.Style) -> NSAttributedString {
        return self.styled(with: style.stringStyle())
    }
    
    func with(style: TextStyle.Style, andColor: UIColor) -> NSAttributedString {
        return self.styled(with: style.stringStyle(),.color(andColor))
    }
    
    func with(style: TextStyle.Style, andColor: UIColor, andLetterSpacing: CGFloat) -> NSAttributedString {
        return self.styled(with: style.stringStyle(),.color(andColor), .tracking(.point(andLetterSpacing)))
    }
}

extension NSAttributedString {
    func with(_ style: TextStyle.Style) -> NSAttributedString {
        return self.styled(with: style.stringStyle())
    }
    
    func with(style: TextStyle.Style, andColor: UIColor) -> NSAttributedString {
        return self.styled(with: style.stringStyle(),.color(andColor))
    }
    
    func with(style: TextStyle.Style, andColor: UIColor, andLetterSpacing: CGFloat) -> NSAttributedString {
        return self.styled(with: style.stringStyle(),.color(andColor), .tracking(.point(andLetterSpacing)))
    }
}
