//
//  SettingsCell.swift
//  Alfred
//

import Foundation
import UIKit

class SettingsCell: UITableViewCell {
	@IBOutlet var descriptionLabel: UILabel!

	override func awakeFromNib() {
		super.awakeFromNib()
		selectionStyle = .none
	}

	func setup(name: String) {
		descriptionLabel.attributedText = name.with(style: .regular17, andColor: UIColor.grey, andLetterSpacing: -0.41)
	}
}
