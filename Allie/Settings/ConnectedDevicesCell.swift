//
//  ConnectedDevicesCell.swift
//  Allie
//
//  Created by Waqar Malik on 11/4/21.
//

import UIKit

class ConnectedDevicesCell: UITableViewCell {
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		commontInit()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}

	private func commontInit() {
		[titleLabel, subtitleLabel, statusLabel, labelStackView, containerStackView, bottomSeperator].forEach { view in
			view.translatesAutoresizingMaskIntoConstraints = false
		}
		labelStackView.addArrangedSubview(titleLabel)
		labelStackView.addArrangedSubview(subtitleLabel)
		containerStackView.addArrangedSubview(labelStackView)
		containerStackView.addArrangedSubview(statusLabel)
		contentView.addSubview(containerStackView)
		NSLayoutConstraint.activate([containerStackView.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 0.0),
		                             containerStackView.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 2.0),
		                             contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: containerStackView.trailingAnchor, multiplier: 1.0),
		                             contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: containerStackView.bottomAnchor, multiplier: 0.0)])

		addSubview(bottomSeperator)
		NSLayoutConstraint.activate([bottomSeperator.leadingAnchor.constraint(equalTo: leadingAnchor),
		                             trailingAnchor.constraint(equalTo: bottomSeperator.trailingAnchor),
		                             bottomAnchor.constraint(equalTo: bottomSeperator.bottomAnchor),
		                             bottomSeperator.heightAnchor.constraint(equalToConstant: 0.5)])
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		titleLabel.text = nil
		titleLabel.attributedText = nil
		subtitleLabel.text = nil
		subtitleLabel.attributedText = nil
		statusLabel.text = nil
		statusLabel.attributedText = nil
	}

	private let bottomSeperator: UIView = {
		let view = UIView(frame: .zero)
		view.backgroundColor = .allieSeparator
		return view
	}()

	let titleLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.textColor = .allieBlack
		label.font = .systemFont(ofSize: 17, weight: .semibold)
		return label
	}()

	let subtitleLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.textColor = .allieGray
		label.font = .systemFont(ofSize: 15.0, weight: .regular)
		return label
	}()

	let statusLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.textColor = .allieLightGray
		label.font = .systemFont(ofSize: 13.0)
		label.textAlignment = .right
		return label
	}()

	let labelStackView: UIStackView = {
		let view = UIStackView(frame: .zero)
		view.axis = .vertical
		view.spacing = 1.0
		view.distribution = .fill
		view.alignment = .fill
		return view
	}()

	let containerStackView: UIStackView = {
		let view = UIStackView(frame: .zero)
		view.axis = .horizontal
		view.spacing = 4.0
		view.distribution = .fill
		view.alignment = .fill
		return view
	}()
}
