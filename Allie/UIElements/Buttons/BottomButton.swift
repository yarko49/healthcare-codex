//
//  BottomButton.swift
//  Allie

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

	func sharedInit() {}

	func setupButton() {
		setupColors()
		addTextSpacing(5.0)
	}

	func refreshCorners(value: CGFloat) {
		layer.cornerRadius = value
	}

	func setupColors() {
		layer.backgroundColor = UIColor.grey.cgColor
	}

	func addTextSpacing(_ letterSpacing: CGFloat) {
		guard let attributedText = titleLabel?.attributedText else { return }
		let attributedString = NSMutableAttributedString(attributedString: attributedText)
		attributedString.addAttribute(NSAttributedString.Key.kern, value: letterSpacing, range: NSRange(location: 0, length: attributedText.string.count))
		setAttributedTitle(attributedString, for: .normal)
	}
}
