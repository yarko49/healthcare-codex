//
//  SettingsCell.swift
//  alfred-ios
//

import Foundation
import UIKit

class SettingsCell: UITableViewCell {
	@IBOutlet var descriptionLbl: UILabel!

	override func awakeFromNib() {
		super.awakeFromNib()
		selectionStyle = .none
	}

	func setup(name: String) {
		descriptionLbl.attributedText = name.with(style: .regular17, andColor: UIColor.grey, andLetterSpacing: -0.41)
	}
}
