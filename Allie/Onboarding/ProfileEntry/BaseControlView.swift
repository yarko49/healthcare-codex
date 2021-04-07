//
//  BaseControlView.swift
//  Allie
//
//  Created by Waqar Malik on 4/4/21.
//

import UIKit

class BaseControlView: UIView {
	let titleLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.text = "Placeholder"
		label.textColor = UIColor.darkText
		label.font = UIFont.systemFont(ofSize: 10.0, weight: .light)
		return label
	}()

	let contentView: UIView = {
		let view = UIView(frame: .zero)
		view.layer.borderWidth = 1.0
		view.layer.borderColor = UIColor.lightGray.cgColor
		view.layer.cornerRadius = 4.0
		view.layer.cornerCurve = .continuous
		return view
	}()

	let labelContainer: UIView = {
		let view = UIView(frame: .zero)
		view.backgroundColor = .onboardingBackground
		return view
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
		contentView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(contentView)
		NSLayoutConstraint.activate([contentView.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 0.6),
		                             contentView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 0.0),
		                             trailingAnchor.constraint(equalToSystemSpacingAfter: contentView.trailingAnchor, multiplier: 0.0),
		                             bottomAnchor.constraint(equalToSystemSpacingBelow: contentView.bottomAnchor, multiplier: 0.0)])

		labelContainer.translatesAutoresizingMaskIntoConstraints = false
		addSubview(labelContainer)
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		addSubview(titleLabel)
		NSLayoutConstraint.activate([titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 0.0),
		                             titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 2.0)])
		NSLayoutConstraint.activate([labelContainer.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
		                             labelContainer.centerXAnchor.constraint(equalTo: titleLabel.centerXAnchor),
		                             labelContainer.heightAnchor.constraint(greaterThanOrEqualTo: titleLabel.heightAnchor, multiplier: 1.0),
		                             labelContainer.widthAnchor.constraint(equalTo: titleLabel.widthAnchor, multiplier: 1.0, constant: 8.0)])
	}
}
