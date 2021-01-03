//  GoogleSignInButton.swift
//  Alfred

import BonMot
import UIKit

class GoogleSignInButton: UIButton {
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
		setImage(UIImage(named: "iconLogoGoogle"), for: .normal)
		titleEdgeInsets.left = 14
		contentEdgeInsets.top = 12
		contentEdgeInsets.bottom = 12
		layer.cornerRadius = 20.0
		layer.borderWidth = 1.0
		layer.borderColor = UIColor.grey.cgColor
		let lbl = UILabel()
		lbl.attributedText = labelTitle?.with(style: .semibold20, andColor: UIColor.google ?? UIColor.black, andLetterSpacing: 0.38)
		setAttributedTitle(lbl.attributedText, for: .normal)
	}

	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		setupView()
	}
}
