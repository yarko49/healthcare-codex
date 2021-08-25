//
//  BGMPairingItem+AttributedText.swift
//  Allie
//
//  Created by Waqar Malik on 8/23/21.
//

import UIKit

extension BGMPairingItem {
	var attributedTitle: NSAttributedString {
		NSAttributedString(string: title, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24.0, weight: .bold), .foregroundColor: UIColor.allieGray])
	}

	var attributedMessage: NSAttributedString? {
		guard let value = message else {
			return nil
		}
		var attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.allieLightGray, .font: UIFont.systemFont(ofSize: 16.0)]
		let attributedString = NSMutableAttributedString(string: value, attributes: attributes)
		let range = (value as NSString).range(of: "6 seconds")
		if range.location != NSNotFound {
			attributes[.font] = UIFont.systemFont(ofSize: 16.0, weight: .bold)
			attributedString.setAttributes(attributes, range: range)
		}

		return attributedString
	}
}
