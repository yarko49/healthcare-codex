//
//  AAPLSignInButton.swift
//  Alfred

import Foundation
import UIKit
@IBDesignable

class AAPLSignInButton: UIButton {
	var labelTitle: String? {
		didSet {
			titleLabel?.attributedText = labelTitle?.with(style: .semibold20, andColor: UIColor.google ?? UIColor.black, andLetterSpacing: 0.38)
		}
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupView()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupView()
	}

	convenience init(labelTitle: String) {
		self.init(frame: CGRect.zero)
		self.labelTitle = labelTitle
		setupView()
	}

	func setupValues(labelTitle: String) {
		self.labelTitle = labelTitle
		setupView()
	}

	private func setupView() {
		setupAccessibility()
		layer.cornerRadius = 20
		layer.masksToBounds = true
		backgroundColor = .black
		tintColor = .white
		let bundle = Bundle(for: classForCoder)
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
		apple.attributedText = labelTitle?.with(style: .semibold20, andColor: UIColor.white, andLetterSpacing: 0.38)
		setAttributedTitle(apple.attributedText, for: .normal)
	}

	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		setupView()
	}
}
