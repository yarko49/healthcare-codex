//
//  SelfSizingCollectionView.swift
//  Allie
//
//  Created by Waqar Malik on 4/29/21.
//

import UIKit

class SelfSizingCollectionView: UICollectionView {
	// MARK: Properties

	private var collectionViewHeightConstraint: NSLayoutConstraint?

	// MARK: Life cycle

	override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
		super.init(frame: frame, collectionViewLayout: layout)
		constrainSubviews()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: Methods

	override func layoutSubviews() {
		super.layoutSubviews()
		let height = collectionViewLayout.collectionViewContentSize.height
		collectionViewHeightConstraint?.constant = max(1, height)
	}

	private func constrainSubviews() {
		translatesAutoresizingMaskIntoConstraints = false
		collectionViewHeightConstraint = heightAnchor.constraint(equalToConstant: 1)
		collectionViewHeightConstraint?.priority = .required - 1
		collectionViewHeightConstraint?.isActive = true
	}
}
