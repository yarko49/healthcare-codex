//
//  Ext_UILabel.swift
//  alfred-ios
//

import UIKit

extension UILabel {
	func heightForView(extraWidth: CGFloat = 0) -> CGFloat {
		let label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width + extraWidth, height: 10))
		label.numberOfLines = 0
		label.lineBreakMode = .byWordWrapping
		label.font = font
		label.text = text

		label.sizeToFit()
		return label.frame.height
	}
}
