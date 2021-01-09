//
//  IllustrationCollectionViewCell.swift
//  Alfred
//
//  Created by Waqar Malik on 1/8/21.
//

import UIKit

class IllustrationCollectionViewCell: UICollectionViewCell {
	override init(frame: CGRect) {
		super.init(frame: frame)
		configureView()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	let imageView: UIImageView = {
		let view = UIImageView(frame: .zero)
		view.contentMode = .center
		view.clipsToBounds = true
		return view
	}()

	let labelsStackView: UIStackView = {
		let view = UIStackView(frame: .zero)
		view.axis = .vertical
		view.alignment = .center
		view.distribution = .fill
		return view
	}()

	let titleLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.font = UIFont.systemFont(ofSize: 28.0, weight: .bold)
		label.textColor = UIColor.darkText
		label.textAlignment = .center
		label.numberOfLines = 2
		return label
	}()

	let subtitleLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.font = UIFont.systemFont(ofSize: 17.0, weight: .regular)
		label.textColor = .lightGrey
		label.textAlignment = .center
		label.numberOfLines = 2
		return label
	}()

	private func configureView() {
		imageView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(imageView)
		NSLayoutConstraint.activate([imageView.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 0.0),
		                             imageView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 0.0),
		                             trailingAnchor.constraint(equalToSystemSpacingAfter: imageView.trailingAnchor, multiplier: 0.0),
		                             imageView.heightAnchor.constraint(equalToConstant: 225.0)])
		labelsStackView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(labelsStackView)
		NSLayoutConstraint.activate([labelsStackView.topAnchor.constraint(equalToSystemSpacingBelow: imageView.bottomAnchor, multiplier: 5.0),
		                             labelsStackView.widthAnchor.constraint(equalToConstant: 268.0),
		                             labelsStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
		                             bottomAnchor.constraint(equalToSystemSpacingBelow: labelsStackView.bottomAnchor, multiplier: 1.0)])
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		labelsStackView.addArrangedSubview(titleLabel)
		subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
		labelsStackView.addArrangedSubview(subtitleLabel)
	}
}
