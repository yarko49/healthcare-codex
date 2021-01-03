//
//  OnboardingView.swift
//  Alfred
//

import Foundation
import UIKit

class OnboardingView: UIView {
	@IBOutlet var contentView: UIView!

	// MARK: - IBOutlets

	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var descLabel: UILabel!

	var title: String = ""
	var descr: String = ""

	override init(frame: CGRect) {
		super.init(frame: frame)
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	convenience init(title: String, descr: String) {
		self.init(frame: CGRect.zero)
		self.title = title
		self.descr = descr
		commonInit()
	}

	func commonInit() {
		Bundle.main.loadNibNamed(Self.nibName, owner: self, options: nil)
		contentView.fixInView(self)
		setup()
	}

	private func setup() {
		titleLabel.attributedText = title.with(style: .bold28, andColor: .black, andLetterSpacing: 0.36)
		descLabel.attributedText = descr.with(style: .regular17, andColor: .lightGrey, andLetterSpacing: -0.32)
	}
}
