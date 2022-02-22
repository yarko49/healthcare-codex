//
//  SectionView.swift
//  Allie
//
//  Created by Onseen on 2/21/22.
//

import UIKit

class SectionView: UICollectionReusableView {
	static let reuseID: String = "SectionView"

	private var title: UILabel = {
		let title = UILabel()
		title.translatesAutoresizingMaskIntoConstraints = false
		title.numberOfLines = 0
		title.lineBreakMode = .byWordWrapping
		return title
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupViews()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupViews() {
		backgroundColor = .clear
		addSubview(title)
		title.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		title.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0).isActive = true
	}

	func configureSection(headerTitle: String) {
		title.attributedText = headerTitle.attributedString(style: .bold24, foregroundColor: .mainBlue)
	}
}
