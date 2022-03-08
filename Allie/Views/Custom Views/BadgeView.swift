//
//  BadgeView.swift
//  Allie
//
//  Created by Onseen on 3/7/22.
//

import UIKit

class BadgeView: UIView {
	var badgeCount: Int? {
		didSet {
			if let badgeCount = badgeCount, badgeCount > 0 {
				backgroundColor = .red
				badgeLabel.isHidden = false
				badgeLabel.text = "\(badgeCount)"
			} else {
				backgroundColor = .clear
				badgeLabel.isHidden = true
			}
			layoutIfNeeded()
			needsUpdateConstraints()
		}
	}

	private let badgeLabel: UILabel = {
		let badgeLabel = UILabel()
		badgeLabel.translatesAutoresizingMaskIntoConstraints = false
		badgeLabel.textAlignment = .center
		badgeLabel.numberOfLines = 1
		badgeLabel.textColor = .white
		badgeLabel.font = .systemFont(ofSize: 12.0)
		return badgeLabel
	}()

	override init(frame: CGRect) {
		super.init(frame: .zero)
		setupViews()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupViews() {
		backgroundColor = .red
		addSubview(badgeLabel)
		badgeLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		badgeLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		badgeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
		badgeLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
		badgeLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
		badgeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 8).isActive = true
		layer.cornerRadius = 12.0
	}
}
