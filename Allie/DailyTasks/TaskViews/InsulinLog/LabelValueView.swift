//
//  LabelValueView.swift
//  Allie
//
//  Created by Waqar Malik on 5/9/21.
//

import CareKitUI
import UIKit

class LabelValueView: OCKStackView {
	override init(style: OCKStackView.Style = .plain) {
		super.init(style: style)
		setup()
	}

	var units: String? {
		get {
			unitLabelValueView.textField.text
		}
		set {
			unitLabelValueView.textField.text = newValue
		}
	}

	var entryDate: Date {
		get {
			timeLabelValueView.timePicker.date
		}
		set {
			timeLabelValueView.timePicker.date = newValue
		}
	}

	let unitLabelValueView: SeperatorLabelValueEntryView = {
		let view = SeperatorLabelValueEntryView(style: .plain)
		view.titleLabel.text = NSLocalizedString("UNITS", comment: "Units")
		view.textField.placeholder = "5.6"
		view.textField.keyboardType = .decimalPad
		return view
	}()

	let timeLabelValueView: TimeValueEntryView = {
		let view = TimeValueEntryView(frame: .zero)
		view.titleLabel.text = NSLocalizedString("TIME", comment: "Time")
		return view
	}()

	func setup() {
		spacing = 8.0
		distribution = .fillEqually
		alignment = .center
		addSubviews()
	}

	func addSubviews() {
		[unitLabelValueView, timeLabelValueView].forEach { view in
			view.translatesAutoresizingMaskIntoConstraints = false
		}
		[unitLabelValueView, timeLabelValueView].forEach { view in
			addArrangedSubview(view)
		}
	}
}

class SeperatorLabelValueEntryView: OCKStackView {
	override init(style: OCKStackView.Style = .plain) {
		super.init(style: style)
		setup()
	}

	var titleLabel: UILabel {
		labelValueView.titleLabel
	}

	var textField: UITextField {
		labelValueView.textField
	}

	let labelValueView: LabelValueEntryView = {
		let view = LabelValueEntryView()
		view.axis = .horizontal
		return view
	}()

	let separtorView: UIView = {
		let view = UIView(frame: .zero)
		view.backgroundColor = .allieSeparator
		view.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
		return view
	}()

	func setup() {
		axis = .vertical
		spacing = 8.0
		distribution = .fill
		alignment = .fill
		addSubviews()
	}

	func addSubviews() {
		[labelValueView, separtorView].forEach { view in
			view.translatesAutoresizingMaskIntoConstraints = false
		}
		[labelValueView, separtorView].forEach { view in
			addArrangedSubview(view)
		}
	}
}

class LabelValueEntryView: OCKStackView {
	override init(style: OCKStackView.Style = .plain) {
		super.init(style: style)
		setup()
	}

	let titleLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.textColor = .allieLighterGray
		return label
	}()

	let textField: UITextField = {
		let view = UITextField(frame: .zero)
		view.font = UIFont.preferredFont(forTextStyle: .subheadline)
		view.textAlignment = .left
		view.textColor = .allieBlack
		return view
	}()

	func setup() {
		axis = .horizontal
		distribution = .fillEqually
		alignment = .center
		spacing = 8.0
		addSubviews()
	}

	func addSubviews() {
		[titleLabel, textField].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
		[titleLabel, textField].forEach { addArrangedSubview($0) }
	}
}

class TimeValueEntryView: UIView {
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}

	@available(*, unavailable)
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	let titleLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.textColor = .allieLighterGray
		return label
	}()

	let timePicker: UIDatePicker = {
		let timePicker = UIDatePicker()
		timePicker.datePickerMode = .time
		timePicker.preferredDatePickerStyle = .automatic
		return timePicker
	}()

	let separtorView: UIView = {
		let view = UIView(frame: .zero)
		view.backgroundColor = .allieSeparator
		view.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
		return view
	}()

	func setup() {
		addSubviews()
	}

	func addSubviews() {
		[titleLabel, timePicker, separtorView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
		[titleLabel, timePicker, separtorView].forEach { addSubview($0) }
		NSLayoutConstraint.activate([titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 0.0),
		                             titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 0.0),
		                             separtorView.topAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 1.0),
		                             titleLabel.widthAnchor.constraint(equalToConstant: 60.0)])
		NSLayoutConstraint.activate([trailingAnchor.constraint(equalToSystemSpacingAfter: timePicker.trailingAnchor, multiplier: 0.0),
		                             timePicker.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -8.0)])
		NSLayoutConstraint.activate([separtorView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 0.0),
		                             trailingAnchor.constraint(equalToSystemSpacingAfter: separtorView.trailingAnchor, multiplier: 0.0),
		                             bottomAnchor.constraint(equalToSystemSpacingBelow: separtorView.bottomAnchor, multiplier: 0.0)])
	}
}
