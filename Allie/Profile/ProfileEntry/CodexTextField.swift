//
//  CodexTextField.swift
//  Allie
//
//  Created by Waqar Malik on 4/4/21.
//

import UIKit

class CodexTextField: BaseControlView {
	let textField: UITextField = {
		let textField = UITextField(frame: .zero)
		textField.borderStyle = .none
		textField.clearButtonMode = .whileEditing
		return textField
	}()

	override func configureView() {
		super.configureView()
		textField.translatesAutoresizingMaskIntoConstraints = false
		addSubview(textField)
		NSLayoutConstraint.activate([textField.leadingAnchor.constraint(equalToSystemSpacingAfter: safeAreaLayoutGuide.leadingAnchor, multiplier: 2.0),
		                             safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: textField.trailingAnchor, multiplier: 2.0),
		                             textField.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 4.0),
		                             textField.centerXAnchor.constraint(equalTo: centerXAnchor)])
	}
}
