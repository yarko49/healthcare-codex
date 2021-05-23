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

	let unitLabelValueView: LabelValueEntryView = {
		let view = LabelValueEntryView(style: .plain)
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

class TimeValueEntryView: UIStackView {
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

	func setup() {
		axis = .horizontal
		distribution = .fill
		alignment = .center
		spacing = 8.0
		addSubviews()
	}

	func addSubviews() {
		[titleLabel, timePicker].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
		[titleLabel, timePicker].forEach { addArrangedSubview($0) }
	}
}
