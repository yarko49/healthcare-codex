//
//  EntryTimePickerNoEntryView.swift
//  Allie
//
//  Created by Onseen on 12/13/21.
//

import CareKitUI
import UIKit

class EntryTimePickerNoValueView: UIView {
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

	var date: Date {
		datePicker.date
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func configure(date: Date?, isActive: Bool) {
		datePicker.date = date ?? Date()
	}

	func values() -> (Date) {
		datePicker.date
	}

	private func commonInit() {
		[stackView, datePicker].forEach { view in
			view.translatesAutoresizingMaskIntoConstraints = false
		}
		addSubview(stackView)
		stackView.addArrangedSubview(datePicker)
		NSLayoutConstraint.activate([stackView.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 0.0),
		                             stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 22.0 / 8.0),
		                             trailingAnchor.constraint(equalToSystemSpacingAfter: stackView.trailingAnchor, multiplier: 22.0 / 8.0),
		                             bottomAnchor.constraint(equalToSystemSpacingBelow: stackView.bottomAnchor, multiplier: 0.0)])
	}
}
