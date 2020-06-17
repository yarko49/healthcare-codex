//
//  TextStyle.swift
//  alfred-ios
//

import Foundation
import BonMot


struct TextStyle {

    enum Style {
        case example


        func stringStyle() -> StringStyle {
            switch self {
            case .example: return exampleStyle
            }
        }
    }


    static let exampleStyle = StringStyle(.color(UIColor.black),.font(Font.example .of(size: 17)))

}

extension String {
    func with(_ style: TextStyle.Style) -> NSAttributedString {
        return self.styled(with: style.stringStyle())
    }
}

extension NSAttributedString {
    func with(_ style: TextStyle.Style) -> NSAttributedString {
        return self.styled(with: style.stringStyle())
    }
}
