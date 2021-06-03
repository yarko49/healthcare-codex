//
//  ShadowView.swift
//  Allie
//
//  Created by Waqar Malik on 5/23/21.
//

import UIKit

class ShadowView: UIView {
	let view: UIView = {
		let view = UIView(frame: .zero)
		view.backgroundColor = .allieSeparator.withAlphaComponent(0.5)
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

	private func configureView() {
		isUserInteractionEnabled = false
		view.translatesAutoresizingMaskIntoConstraints = false
		addSubview(view)
		NSLayoutConstraint.activate([view.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 0.0),
		                             view.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 0.0),
		                             trailingAnchor.constraint(equalToSystemSpacingAfter: view.trailingAnchor, multiplier: 0.0),
		                             view.heightAnchor.constraint(equalToConstant: 0.5)])
		view.layer.shadowColor = UIColor.allieSeparator.cgColor
		view.layer.shadowOpacity = 0.75
		view.layer.shadowRadius = 10.0
		view.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
		view.clipsToBounds = false
	}
}
