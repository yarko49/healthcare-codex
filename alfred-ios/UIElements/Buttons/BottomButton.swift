//
//  BottomButton.swift
//  alfred-ios


import UIKit

@IBDesignable class BottomButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 5 {
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
    }

    func setupButton() {
        setupColors()
        addTextSpacing(5.0)
    }

    func refreshCorners(value: CGFloat) {
        self.layer.cornerRadius = value
    }

    func setupColors() {
        self.layer.backgroundColor = UIColor.grey.cgColor
    }

    func addTextSpacing(_ letterSpacing: CGFloat){
        guard let attributedText = self.titleLabel?.attributedText else {return}
        let attributedString = NSMutableAttributedString(attributedString: attributedText)
        attributedString.addAttribute(NSAttributedString.Key.kern, value: letterSpacing, range: NSRange(location: 0, length: attributedText.string.count))
        self.setAttributedTitle(attributedString, for: .normal)
    }
    
   
}
