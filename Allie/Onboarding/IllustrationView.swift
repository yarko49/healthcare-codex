//
//  IllustrationView.swift
//  Allie
//
//  Created by Waqar Malik on 1/19/21.
//

import UIKit

class IllustrationView: UIStackView {
	override init(frame: CGRect) {
		super.init(frame: frame)
		configureView()
	}

	@available(*, unavailable)
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	let imageView: UIImageView = {
		let view = UIImageView(frame: .zero)
		view.contentMode = .bottom
		view.clipsToBounds = true
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	let titleLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.font = UIFont.systemFont(ofSize: 20.0, weight: .bold)
		label.textColor = .allieGray
		label.textAlignment = .center
		label.numberOfLines = 2
		label.translatesAutoresizingMaskIntoConstraints = false
		label.widthAnchor.constraint(equalToConstant: 280.0).isActive = true
		return label
	}()

	private func configureView() {
		axis = .vertical
		alignment = .center
		distribution = .fill
		spacing = 30.0
		addArrangedSubview(imageView)
		addArrangedSubview(titleLabel)
	}
}
