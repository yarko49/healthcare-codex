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

	class var defaultHeight: CGFloat {
		450.0
	}

	let illustrationView: IllustrationView = {
		let view = IllustrationView(frame: .zero)
		return view
	}()

	private func configureView() {
		illustrationView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(illustrationView)
		NSLayoutConstraint.activate([illustrationView.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 0.0),
		                             illustrationView.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 0.0),
		                             contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: illustrationView.trailingAnchor, multiplier: 0.0),
		                             contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: illustrationView.bottomAnchor, multiplier: 0.0)])
	}
}
