//
//  ConnectedDevicesCell.swift
//  Allie
//
//  Created by Waqar Malik on 11/4/21.
//

import UIKit

class ConnectedDevicesCell: UITableViewCell {
	private let bottomSeperator: UIView = {
		let view = UIView(frame: .zero)
		view.backgroundColor = .allieSeparator
		return view
	}()

	let titleLabel: UILabel = {
		let label = UILabel(frame: .zero)
		return label
	}()

	let subtitleLabel: UILabel = {
		let label = UILabel(frame: .zero)
		return label
	}()

	let statusLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.textAlignment = .right
		return label
	}()

	let labelStackView: UIStackView = {
		let view = UIStackView(frame: .zero)
		view.axis = .vertical
		view.spacing = 1.0
		view.distribution = .fill
		view.alignment = .leading
		return view
	}()

	let containerStackView: UIStackView = {
		let view = UIStackView(frame: .zero)
		view.axis = .horizontal
		view.spacing = 4.0
		view.distribution = .fill
		view.alignment = .center
		return view
	}()

	let iconImageView: UIImageView = {
		let iconImageView = UIImageView()
		iconImageView.contentMode = .scaleAspectFit
		iconImageView.image = #imageLiteral(resourceName: "icon-empty.pdf")
		iconImageView.layer.masksToBounds = true
		iconImageView.layer.cornerRadius = 12
		return iconImageView
	}()

	let trailingImageView: UIImageView = {
		let trailingImageView = UIImageView()
		trailingImageView.contentMode = .scaleAspectFit
		return trailingImageView
	}()

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
		[titleLabel, subtitleLabel, statusLabel, labelStackView, containerStackView, bottomSeperator, iconImageView, trailingImageView].forEach { view in
			view.translatesAutoresizingMaskIntoConstraints = false
		}
		labelStackView.addArrangedSubview(titleLabel)
		labelStackView.addArrangedSubview(subtitleLabel)
		containerStackView.addArrangedSubview(iconImageView)
		containerStackView.addArrangedSubview(labelStackView)
		containerStackView.addArrangedSubview(statusLabel)
		containerStackView.addArrangedSubview(trailingImageView)
		contentView.addSubview(containerStackView)
		NSLayoutConstraint.activate([iconImageView.heightAnchor.constraint(equalToConstant: 24.0),
		                             iconImageView.widthAnchor.constraint(equalToConstant: 24.0)])

		NSLayoutConstraint.activate([trailingImageView.heightAnchor.constraint(equalToConstant: 20.0),
		                             trailingImageView.widthAnchor.constraint(equalToConstant: 20.0)])

		NSLayoutConstraint.activate([containerStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
		                             containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15.0),
		                             contentView.trailingAnchor.constraint(equalTo: containerStackView.trailingAnchor, constant: 10.0)])

		addSubview(bottomSeperator)
		NSLayoutConstraint.activate([bottomSeperator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
		                             trailingAnchor.constraint(equalTo: bottomSeperator.trailingAnchor, constant: 20),
		                             bottomAnchor.constraint(equalTo: bottomSeperator.bottomAnchor),
		                             bottomSeperator.heightAnchor.constraint(equalToConstant: 1.0)])
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
}
