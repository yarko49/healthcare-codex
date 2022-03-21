//
//  DatePickerView.swift
//  Allie
//
//  Created by Waqar Malik on 4/4/21.
//

import SkyFloatingLabelTextField
import UIKit

class DatePickerView: UIView {
	var textField: SkyFloatingLabelTextField = {
		let textField = SkyFloatingLabelTextField(frame: .zero)
		textField.lineHeight = 1.0
		textField.selectedLineHeight = 1.0
		textField.lineColor = .allieSeparator
		textField.selectedLineColor = .allieSeparator
		textField.placeholder = NSLocalizedString("DATE_OF_BIRTH", comment: "Date of birth")
		textField.selectedTitleColor = .allieSeparator
		textField.titleFont = TextStyle.silkamedium14.font
		textField.font = TextStyle.silkabold17.font
		textField.selectedTitle = NSLocalizedString("DATE_OF_BIRTH", comment: "Date of birth")
		textField.autocorrectionType = .no
		textField.keyboardType = .default
		textField.autocapitalizationType = .none
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.isUserInteractionEnabled = false
		textField.titleFormatter = { text in
			text
		}
		return textField
	}()

	var dateButton: UIButton = {
		let dateButton = UIButton()
		dateButton.translatesAutoresizingMaskIntoConstraints = false
		dateButton.backgroundColor = .mainBlue
		dateButton.layer.cornerRadius = 4.0
		dateButton.isHidden = true
		return dateButton
	}()

	var actionButton: UIButton = {
		let actionButton = UIButton()
		actionButton.translatesAutoresizingMaskIntoConstraints = false
		actionButton.setTitle(nil, for: .normal)
		actionButton.backgroundColor = .clear
		return actionButton
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
		NSLayoutConstraint.activate([textField.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 0.0),
		                             textField.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 0.0),
		                             trailingAnchor.constraint(equalToSystemSpacingAfter: textField.trailingAnchor, multiplier: 0.0),
		                             bottomAnchor.constraint(equalToSystemSpacingBelow: textField.bottomAnchor, multiplier: 0.0)])
		addSubview(dateButton)
		NSLayoutConstraint.activate([bottomAnchor.constraint(equalToSystemSpacingBelow: dateButton.bottomAnchor, multiplier: 0.2),
		                             leadingAnchor.constraint(equalToSystemSpacingAfter: dateButton.leadingAnchor, multiplier: 0.0),
		                             dateButton.widthAnchor.constraint(equalToConstant: 130),
		                             dateButton.heightAnchor.constraint(equalToConstant: 30)])
		addSubview(actionButton)
		NSLayoutConstraint.activate([actionButton.centerXAnchor.constraint(equalTo: centerXAnchor),
		                             actionButton.centerYAnchor.constraint(equalTo: centerYAnchor),
		                             actionButton.leadingAnchor.constraint(equalTo: leadingAnchor),
		                             actionButton.topAnchor.constraint(equalTo: topAnchor)])
	}
}
