//
//  emailSignInButton.swift
//  alfred-ios


import Foundation
import UIKit


class EmailSignInButton : UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        titleEdgeInsets.left = 14
        contentEdgeInsets.top = 12
        contentEdgeInsets.bottom = 12
        self.layer.cornerRadius = 20.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.grey.cgColor
        let lbl = UILabel()
        lbl.attributedText = Str.signInWithYourEmail.with(style: .regular20, andColor: UIColor.grey , andLetterSpacing: 0.38)
        setAttributedTitle(lbl.attributedText, for: .normal)
        
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
    
    
    
}

