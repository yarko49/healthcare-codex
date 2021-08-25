//
//  BGMPairingPageViewController.swift
//  Allie
//
//  Created by Waqar Malik on 8/23/21.
//

import UIKit

class BGMPairingPageViewController: UIViewController {
	var item: BGMPairingItem? {
		didSet {
			configureView()
		}
	}

	let imageView: UIImageView = {
		let view = UIImageView(frame: .zero)
		view.contentMode = .scaleAspectFit
		return view
	}()

	let titleLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.textColor = .allieGray
		label.numberOfLines = 0
		label.font = UIFont.systemFont(ofSize: 24.0, weight: .bold)
		label.textAlignment = .center
		return label
	}()

	let subtitleLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.textColor = .allieLightGray
		label.numberOfLines = 0
		label.font = UIFont.systemFont(ofSize: 16.0, weight: .regular)
		label.textAlignment = .center
		return label
	}()

	private let stackView: UIStackView = {
		let view = UIStackView(frame: .zero)
		view.axis = .vertical
		view.distribution = .fill
		view.alignment = .fill
		view.spacing = 16.0
		return view
	}()

	override func viewDidLoad() {
		super.viewDidLoad()

		[imageView, titleLabel, subtitleLabel, stackView].forEach { view in
			view.translatesAutoresizingMaskIntoConstraints = false
		}
		view.addSubview(stackView)
		NSLayoutConstraint.activate([stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 5.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: stackView.trailingAnchor, multiplier: 5.0),
		                             stackView.centerYAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.centerYAnchor, multiplier: 0.0)])
		stackView.addArrangedSubview(imageView)
		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(subtitleLabel)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		configureView()
	}

	private func configureView() {
		guard let item = item else {
			return
		}
		imageView.image = UIImage(named: item.imageName)
		titleLabel.attributedText = item.attributedTitle
		subtitleLabel.attributedText = item.attributedMessage
	}
}
