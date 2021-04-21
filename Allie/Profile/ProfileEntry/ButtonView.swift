//
//  ButtonView.swift
//  Allie
//
//  Created by Waqar Malik on 4/4/21.
//

import UIKit

class ButtonView: BaseControlView {
	let button: UIButton = {
		let button = UIButton(type: .custom)
		button.setTitleColor(.darkText, for: .normal)
		button.contentHorizontalAlignment = .leading
		return button
	}()

	override func configureView() {
		super.configureView()
		button.translatesAutoresizingMaskIntoConstraints = false
		addSubview(button)
		NSLayoutConstraint.activate([button.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 2.0),
		                             button.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 2.0),
		                             trailingAnchor.constraint(equalToSystemSpacingAfter: button.trailingAnchor, multiplier: 2.0),
		                             bottomAnchor.constraint(equalToSystemSpacingBelow: button.bottomAnchor, multiplier: 1.0)])
	}
}
