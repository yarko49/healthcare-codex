//
//  EntryTimePickerView.swift
//  Allie
//
//  Created by Waqar Malik on 7/7/21.
//

import CareKitUI
import UIKit

class EntryTimePickerView: UIView {
	class var height: CGFloat {
		45.0
	}

	class var reuseIdentifier: String {
		String(describing: self)
	}

	let stackView: OCKStackView = {
		let view = OCKStackView()
		view.axis = .horizontal
		view.distribution = .fill
		view.alignment = .fill
		view.spacing = 10.0
		return view
	}()

	let datePicker: UIDatePicker = {
		let picker = UIDatePicker(frame: .zero)
		picker.date = Date()
		picker.preferredDatePickerStyle = .compact
		picker.datePickerMode = .dateAndTime
		return picker
	}()

	var value: String? {
		labelEntry.textField.text
	}

	var canEditValue: Bool {
		get {
			labelEntry.textField.isEnabled
		}
		set {
			labelEntry.textField.isEnabled = newValue
		}
	}

	var date: Date {
		datePicker.date
	}

	let labelEntry: EntryLabeledTextEntryView = {
		let view = EntryLabeledTextEntryView(frame: .zero)
		return view
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	var keyboardType: UIKeyboardType {
		get {
			labelEntry.textField.keyboardType
		}
		set {
			labelEntry.textField.keyboardType = newValue
		}
	}

	func configure(placeHolder: String, value: String?, unitTitle: String, date: Date?, isActive: Bool) {
		datePicker.date = date ?? Date()
		labelEntry.textField.placeholder = placeHolder
		labelEntry.textLabel.text = unitTitle
		labelEntry.textField.text = value
		if isActive {
			labelEntry.textField.becomeFirstResponder()
		}
	}

	func values() -> (String, Date) {
		(labelEntry.textField.text ?? "", datePicker.date)
	}

	private func commonInit() {
		[stackView, datePicker, labelEntry].forEach { view in
			view.translatesAutoresizingMaskIntoConstraints = false
		}
		addSubview(stackView)
		stackView.addArrangedSubview(labelEntry)
		stackView.addArrangedSubview(datePicker)
		NSLayoutConstraint.activate([stackView.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 0.0),
		                             stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 22.0 / 8.0),
		                             trailingAnchor.constraint(equalToSystemSpacingAfter: stackView.trailingAnchor, multiplier: 22.0 / 8.0),
		                             bottomAnchor.constraint(equalToSystemSpacingBelow: stackView.bottomAnchor, multiplier: 0.0)])
	}
}
