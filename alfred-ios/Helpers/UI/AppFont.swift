//
//  AppFont.swift
//  alfred-ios
//

import UIKit

enum Font: String {
    case example = "Example-Font"

    
    func of(size: CGFloat) -> UIFont {
        guard let font = UIFont(name: self.rawValue, size: size) else {
            fatalError("\(self.rawValue) font is not installed, make sure it added in Info.plist and logged with Font.logAllAvailableFonts()")
        }
        return font
    }
    
    static func logAllAvailableFonts() {
        for family in UIFont.familyNames {
            print("\(family)")
            for name in UIFont.fontNames(forFamilyName: family) {
                print("   \(name)")
            }
        }
    }
}
