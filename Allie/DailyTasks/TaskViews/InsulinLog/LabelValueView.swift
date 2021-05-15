//
//  LabelValueView.swift
//  Allie
//
//  Created by Waqar Malik on 5/9/21.
//

import CareKitUI
import UIKit

class LabelValuesView: OCKStackView {
	override init(style: OCKStackView.Style = .plain) {
		super.init(style: style)
		setup()
	}

	var units: String? {
		get {
			unitLabelValueView.labelValueEntryView.textField.text
		}
		set {
			unitLabelValueView.labelValueEntryView.textField.text = newValue
		}
	}

	var entryDate: Date {
		get {
			timeLabelValueView.timeValueEntryView.timePicker.date
		}
		set {
			timeLabelValueView.timeValueEntryView.timePicker.date = newValue
		}
	}

	let unitLabelValueView: LabelValueView = {
		let view = LabelValueView(style: .separated)
		view.axis = .vertical
		view.showsOuterSeparators = false
		view.labelValueEntryView.titleLabel.text = NSLocalizedString("UNITS", comment: "Units")
		view.labelValueEntryView.textField.placeholder = "5.6"
		view.labelValueEntryView.textField.keyboardType = .decimalPad
		return view
	}()

	let timeLabelValueView: TimeLabelValueView = {
		let view = TimeLabelValueView(style: .separated)
		view.axis = .vertical
		view.showsOuterSeparators = false
		view.timeValueEntryView.titleLabel.text = NSLocalizedString("TIME", comment: "Time")
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

class LabelValueView: OCKStackView {
	override init(style: OCKStackView.Style = .plain) {
		super.init(style: style)
		setup()
	}

	let labelValueEntryView: LabelValueEntryView = {
		let view = LabelValueEntryView()
		return view
	}()

	func setup() {
		addSubviews()
	}

	func addSubviews() {
		labelValueEntryView.translatesAutoresizingMaskIntoConstraints = false
		addArrangedSubview(labelValueEntryView)
	}
}

class TimeLabelValueView: OCKStackView {
	override init(style: OCKStackView.Style = .plain) {
		super.init(style: style)
		setup()
	}

	let timeValueEntryView: TimeValueEntryView = {
		let view = TimeValueEntryView()
		return view
	}()

	func setup() {
		addSubviews()
	}

	func addSubviews() {
		timeValueEntryView.translatesAutoresizingMaskIntoConstraints = false
		addArrangedSubview(timeValueEntryView)
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

class TimeValueEntryView: OCKStackView {
	override init(style: OCKStackView.Style = .plain) {
		super.init(style: style)
		setup()
	}

	let titleLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.textColor = .allieLighterGray
		return label
	}()

	let timePicker: UIDatePicker = {
		let timePicker = UIDatePicker()
		timePicker.datePickerMode = .time
		timePicker.preferredDatePickerStyle = .compact
		return timePicker
	}()

	func setup() {
		axis = .horizontal
		distribution = .fillProportionally
		alignment = .center
		spacing = 8.0
		addSubviews()
	}

	func addSubviews() {
		[titleLabel, timePicker].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
		[titleLabel, timePicker].forEach { addArrangedSubview($0) }
	}
}
