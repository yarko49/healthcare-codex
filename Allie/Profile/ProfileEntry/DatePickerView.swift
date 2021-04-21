//
//  DatePickerView.swift
//  Allie
//
//  Created by Waqar Malik on 4/4/21.
//

import UIKit

class DatePickerView: BaseControlView {
	let imageView: UIImageView = {
		let view = UIImageView(frame: .zero)
		view.contentMode = .center
		view.image = UIImage(systemName: "calendar")
		return view
	}()

	let detailTextLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.textColor = .lightGray
		label.text = NSLocalizedString("DATE_OF_BIRTH", comment: "Date of birth")
		return label
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
		picker.preferredDatePickerStyle = .compact
		return picker
	}()

	let stackView: UIStackView = {
		let view = UIStackView(frame: .zero)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .horizontal
		view.spacing = 8.0
		view.distribution = .fill
		view.alignment = .center
		return view
	}()

	override func configureView() {
		super.configureView()
		addSubview(stackView)
		addSubview(datePicker)
		NSLayoutConstraint.activate([stackView.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 0.5),
		                             stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1.0),
		                             bottomAnchor.constraint(equalToSystemSpacingBelow: stackView.bottomAnchor, multiplier: 0.0)])
		NSLayoutConstraint.activate([trailingAnchor.constraint(equalToSystemSpacingAfter: datePicker.trailingAnchor, multiplier: 1.0),
		                             datePicker.centerYAnchor.constraint(equalTo: stackView.centerYAnchor)])
		stackView.addArrangedSubview(imageView)
		stackView.addArrangedSubview(detailTextLabel)
		titleLabel.isHidden = true
		labelContainer.isHidden = true
		contentView.backgroundColor = datePicker.backgroundColor
	}
}
