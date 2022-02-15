//
//  RiseSleepCell.swift
//  Allie
//
//  Created by Onseen on 1/26/22.
//

import UIKit

enum RiseSleepType {
	case rise, sleep
}

class RiseSleepCell: UICollectionViewCell {
	static let cellID: String = "RiseSleepCell"

	var cellType: RiseSleepType! {
		didSet {
			if cellType == .rise {
				imageView.image = UIImage(systemName: "sun.min")
				title.text = "Rise and shine!"
			} else {
				imageView.image = UIImage(systemName: "sun.haze")
				title.text = "Sleep well!"
			}
		}
	}

	private var imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.tintColor = .mainGray
		return imageView
	}()

	private var title: UILabel = {
		let title = UILabel()
		title.translatesAutoresizingMaskIntoConstraints = false
		title.textColor = .mainGray
		title.font = .systemFont(ofSize: 14)
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

	func setupViews() {
		backgroundColor = .clear
		contentView.addSubview(imageView)
		contentView.addSubview(title)
		imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
		imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 34).isActive = true
		imageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
		imageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
		imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
		title.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
		title.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 16).isActive = true
	}
}
