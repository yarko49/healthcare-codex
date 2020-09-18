//
//  AAPLSignInButton.swift
//  alfred-ios

import Foundation
import UIKit
@IBDesignable

class AAPLSignInButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        setupAccessibility()
        layer.cornerRadius = 20
        layer.masksToBounds = true
        backgroundColor = .black
        tintColor = .white
        
        let bundle = Bundle(for: self.classForCoder)
        setImage(UIImage(named: "whiteAppleLogo", in: bundle, compatibleWith: traitCollection), for: .normal)
        titleEdgeInsets.left = 14
        contentEdgeInsets.top = 11
        contentEdgeInsets.bottom = 12
 
    }
    
    private func setupAccessibility() {
        setTitle(Str.signInWithApple, for: .normal)
        titleLabel?.font = .preferredFont(forTextStyle: .body)
        adjustsImageSizeForAccessibilityContentSizeCategory = true
        titleLabel?.adjustsFontForContentSizeCategory = true
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.minimumScaleFactor = 0.5
        let apple = UILabel()
        apple.attributedText = Str.signInWithApple.with(style: .semibold20, andColor: UIColor.white , andLetterSpacing: 0.38)
        setAttributedTitle(apple.attributedText, for: .normal)


    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
}

