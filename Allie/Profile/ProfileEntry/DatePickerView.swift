//
//  DatePickerView.swift
//  Allie
//
//  Created by Waqar Malik on 4/4/21.
//

import SkyFloatingLabelTextField
import UIKit

class DatePickerView: UIView {
	let textField: SkyFloatingLabelTextField = {
		let textField = SkyFloatingLabelTextField(frame: .zero)
		textField.lineHeight = 1.0
		textField.selectedLineHeight = 1.0
		textField.lineColor = .allieSeparator
		textField.selectedLineColor = .allieSeparator
		textField.placeholder = NSLocalizedString("DATE_OF_BIRTH", comment: "Date of birth")
		textField.selectedTitleColor = .allieSeparator
		textField.selectedTitle = NSLocalizedString("DATE_OF_BIRTH", comment: "Date of birth")
		textField.autocorrectionType = .no
		textField.keyboardType = .default
		textField.autocapitalizationType = .none
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.isUserInteractionEnabled = false
		return textField
	}()

	var datePicker: UIDatePicker = {
		let picker = UIDatePicker()
		picker.translatesAutoresizingMaskIntoConstraints = false
		let calendar = Calendar.current
		picker.datePickerMode = .date
		var dateComponents = DateComponents()
		let epoch = Date(timeIntervalSince1970: 0)
		dateComponents.year = -50
		dateComponents.month = 0
		dateComponents.day = 0
		picker.minimumDate = calendar.date(byAdding: dateComponents, to: epoch)
		dateComponents.year = 70
		picker.maximumDate = calendar.date(byAdding: dateComponents, to: epoch)
		picker.setDate(epoch, animated: false)
		picker.preferredDatePickerStyle = .automatic
		return picker
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
		addSubview(datePicker)
		NSLayoutConstraint.activate([bottomAnchor.constraint(equalToSystemSpacingBelow: datePicker.bottomAnchor, multiplier: 0.2),
		                             trailingAnchor.constraint(equalToSystemSpacingAfter: datePicker.trailingAnchor, multiplier: 0.0)])
	}
}
