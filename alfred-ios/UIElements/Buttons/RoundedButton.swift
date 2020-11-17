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

	@IBInspectable var roundedBackgroundColor: CGColor? = UIColor.blue?.cgColor {
		didSet {
			setBackgroundColor()
		}
	}

	@IBInspectable var roundedTitleColor: UIColor? = .white {
		didSet {
			setTitleColor()
		}
	}

	@IBInspectable var roundedBorderColor: CGColor? = UIColor.blue?.cgColor {
		didSet {
			setBorderColor()
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
		setBackgroundColor()
		setTitleColor()
		setBorderColor()
	}

	func setBackgroundColor() {
		layer.backgroundColor = roundedBackgroundColor
	}

	func setTitleColor() {
		setTitleColor(roundedTitleColor, for: .normal)
	}

	func setBorderColor() {
		layer.borderWidth = 2
		layer.borderColor = roundedBorderColor
	}

	func refreshCorners(value: CGFloat) {
		layer.cornerRadius = value
	}
}
