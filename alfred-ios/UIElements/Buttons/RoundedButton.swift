//
//  RoundedButton.swift
//  alfred-ios
//

import UIKit

@IBDesignable class RoundedButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 8 {
        didSet {
            refreshCorners(value: cornerRadius)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    override func prepareForInterfaceBuilder() {
        sharedInit()
    }
    
    func sharedInit() {
        setupColors()
        refreshCorners(value: cornerRadius)
    }
    
    func setupColors() {
        self.layer.backgroundColor = UIColor.blue.cgColor
        self.setTitleColor(.white, for: .normal)
    }
    
    func refreshCorners(value: CGFloat) {
        self.layer.cornerRadius = value
    }
}
