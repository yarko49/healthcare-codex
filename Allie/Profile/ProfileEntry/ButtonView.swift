//
//  ButtonView.swift
//  Allie
//
//  Created by Waqar Malik on 4/4/21.
//

import SkyFloatingLabelTextField
import UIKit

class ButtonView: UIView {
	let textField: SkyFloatingLabelTextField = {
		let textField = SkyFloatingLabelTextField(frame: .zero)
		textField.lineHeight = 1.0
		textField.selectedLineHeight = 1.0
		textField.lineColor = .allieSeparator
		textField.selectedLineColor = .allieSeparator
		textField.selectedTitleColor = .allieSeparator
		textField.autocorrectionType = .no
		textField.keyboardType = .default
		textField.autocapitalizationType = .none
		textField.isUserInteractionEnabled = false
		return textField
	}()

	let button: UIButton = {
		let button = UIButton(type: .custom)
		button.setTitleColor(.darkText, for: .normal)
		button.contentHorizontalAlignment = .leading
		return button
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		configureView()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func configureView() {
		addSubview(textField)
		textField.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([textField.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 0.0),
		                             textField.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 0.0),
		                             trailingAnchor.constraint(equalToSystemSpacingAfter: textField.trailingAnchor, multiplier: 0.0),
		                             bottomAnchor.constraint(equalToSystemSpacingBelow: textField.bottomAnchor, multiplier: 0.0)])
		button.translatesAutoresizingMaskIntoConstraints = false
		addSubview(button)
		NSLayoutConstraint.activate([button.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 10.0),
		                             trailingAnchor.constraint(equalToSystemSpacingAfter: button.trailingAnchor, multiplier: 0.0),
		                             bottomAnchor.constraint(equalToSystemSpacingBelow: button.bottomAnchor, multiplier: 0.0)])
	}
}
