//
//  SeparatorView.swift
//  Allie
//
//  Created by Waqar Malik on 4/18/21.
//

import UIKit

class SeparatorView: UIView {
	override init(frame: CGRect) {
		super.init(frame: frame)
		configureView()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	let separatorView: UIView = {
		let view = UIView(frame: .zero)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
		view.backgroundColor = .allieSeparator
		return view
	}()

	let titleLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = UIFont.systemFont(ofSize: 14.0, weight: .bold)
		label.textAlignment = .center
		label.backgroundColor = .allieWhite
		label.textColor = .allieLightText
		label.text = NSLocalizedString("ALREADY_MEMBER", comment: "Already a memeber?")
		return label
	}()

	func configureView() {
		addSubview(separatorView)
		NSLayoutConstraint.activate([separatorView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 0.0),
		                             trailingAnchor.constraint(equalToSystemSpacingAfter: separatorView.trailingAnchor, multiplier: 0.0),
		                             separatorView.centerYAnchor.constraint(equalTo: centerYAnchor)])

		addSubview(titleLabel)
		NSLayoutConstraint.activate([titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
		                             titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor)])
	}
}
