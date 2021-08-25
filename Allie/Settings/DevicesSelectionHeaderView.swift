//
//  DevicesSelectionHeaderView.swift
//  Allie
//
//  Created by Waqar Malik on 8/16/21.
//

import UIKit

class DevicesSelectionHeaderView: UITableViewHeaderFooterView {
	class var height: CGFloat {
		54.0
	}

	let titleLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.textColor = .allieGray
		label.font = UIFont.systemFont(ofSize: 17.0, weight: .semibold)
		label.textAlignment = .center
		return label
	}()

	override init(reuseIdentifier: String?) {
		super.init(reuseIdentifier: reuseIdentifier)
		commonInit()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		titleLabel.text = nil
	}

	private func commonInit() {
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(titleLabel)
		let view = UIView(frame: .zero)
		view.backgroundColor = .white
		backgroundView = view
		NSLayoutConstraint.activate([titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 2.0),
		                             contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: titleLabel.trailingAnchor, multiplier: 2.0),
		                             titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1.0),
		                             contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 1.0)])
	}
}
