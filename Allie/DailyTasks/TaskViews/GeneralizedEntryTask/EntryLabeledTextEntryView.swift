//
//  EntryLabeledTextEntryView.swift
//  Allie
//
//  Created by Waqar Malik on 7/7/21.
//

import CareKitUI
import UIKit

class EntryLabeledTextEntryView: UIView {
	let stackView: OCKStackView = {
		let view = OCKStackView()
		view.axis = .horizontal
		view.distribution = .fillEqually
		view.alignment = .fill
		return view
	}()

	let textField: UITextField = {
		let textField = UITextField(frame: .zero)
		textField.textColor = .allieBlack
		textField.autocorrectionType = .no
		textField.autocapitalizationType = .none
		textField.keyboardType = .decimalPad
		return textField
	}()

	let textLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.textColor = .allieLighterGray
		label.textAlignment = .right
		label.font = UIFont.systemFont(ofSize: 16.0, weight: .regular)
		return label
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func commonInit() {
		layer.borderWidth = 1.0
		layer.borderColor = UIColor.allieLighterGray.withAlphaComponent(0.5).cgColor
		layer.cornerRadius = 8.0
		layer.cornerCurve = .continuous

		[stackView, textField, textLabel].forEach { view in
			view.translatesAutoresizingMaskIntoConstraints = false
		}
		addSubview(stackView)
		NSLayoutConstraint.activate([stackView.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 0.0),
		                             stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1.0),
		                             trailingAnchor.constraint(equalToSystemSpacingAfter: stackView.trailingAnchor, multiplier: 1.0),
		                             bottomAnchor.constraint(equalToSystemSpacingBelow: stackView.bottomAnchor, multiplier: 0.0)])
		stackView.addArrangedSubview(textField)
		stackView.addArrangedSubview(textLabel)
	}
}
