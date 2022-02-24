//
//  FollowCell.swift
//  Allie
//
//  Created by Onseen on 2/18/22.
//

import UIKit

class FollowCell: UITableViewCell {
	static let cellID: String = "FollowCell"

	private var container: UIView = {
		let container = UIView()
		container.translatesAutoresizingMaskIntoConstraints = false
		container.layer.cornerRadius = 12.0
		return container
	}()

	private var checkButton: UIButton = {
		let checkButton = UIButton()
		checkButton.translatesAutoresizingMaskIntoConstraints = false
		checkButton.layer.cornerRadius = 22.0
		checkButton.layer.borderWidth = 1.0
		checkButton.setTitle("", for: .normal)
		checkButton.tintColor = .white
		return checkButton
	}()

	private var title: UILabel = {
		let title = UILabel()
		title.translatesAutoresizingMaskIntoConstraints = false
		title.numberOfLines = 0
		title.lineBreakMode = .byWordWrapping
		return title
	}()

	override func awakeFromNib() {
		super.awakeFromNib()
		setupViews()
	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupViews()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupViews() {
		backgroundColor = .clear
		contentView.backgroundColor = .clear
		contentView.addSubview(container)
		container.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
		container.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
		container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
		container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12.0).isActive = true

		[checkButton, title].forEach { container.addSubview($0) }

		checkButton.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
		checkButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12.0).isActive = true
		checkButton.widthAnchor.constraint(equalToConstant: 44.0).isActive = true
		checkButton.heightAnchor.constraint(equalToConstant: 44.0).isActive = true

		title.centerYAnchor.constraint(equalTo: checkButton.centerYAnchor).isActive = true
		title.leadingAnchor.constraint(equalTo: checkButton.trailingAnchor, constant: 20.0).isActive = true
	}

	func configureCell(follow: FollowModel) {
		container.backgroundColor = follow.isSelected ? .white : .clear
		if follow.isSelected {
			checkButton.layer.borderColor = UIColor.mainBlue?.cgColor
			checkButton.backgroundColor = .mainBlue
			checkButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
		} else {
			checkButton.layer.borderColor = UIColor.black.cgColor
			checkButton.backgroundColor = .clear
			checkButton.setImage(nil, for: .normal)
		}
		title.attributedText = follow.title.attributedString(style: .bold20, foregroundColor: .black, letterSpacing: 0)
	}
}
