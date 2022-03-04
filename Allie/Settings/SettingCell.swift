//
//  SettingCell.swift
//  Allie
//
//  Created by Onseen on 3/4/22.
//

import Foundation
import UIKit

class SettingCell: UITableViewCell {
	static let cellID: String = "SettingCell"

	private var container: UIView = {
		let container = UIView()
		container.translatesAutoresizingMaskIntoConstraints = false
		container.backgroundColor = .white
		container.layer.cornerRadius = 12.0
		container.layer.masksToBounds = true
		container.setShadow()
		return container
	}()

	private var title: UILabel = {
		let title = UILabel()
		title.translatesAutoresizingMaskIntoConstraints = false
		return title
	}()

	private var trailingIcon: UIImageView = {
		let trailingIcon = UIImageView()
		trailingIcon.translatesAutoresizingMaskIntoConstraints = false
		trailingIcon.image = UIImage(systemName: "chevron.right")
		trailingIcon.tintColor = .black
		return trailingIcon
	}()

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupViews()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func setupViews() {
		backgroundColor = .clear
		contentView.backgroundColor = .clear
		contentView.addSubview(container)
		container.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
		container.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
		container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
		container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true

		[title, trailingIcon].forEach { container.addSubview($0) }
		title.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
		title.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16).isActive = true
		trailingIcon.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
		trailingIcon.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16).isActive = true
	}

	func configureCell(type: SettingsType) {
		title.attributedText = type.title.attributedString(style: .semibold17, foregroundColor: .allieBlack, letterSpacing: -0.41)
		if type == .feedback {
			let badgeHub = BadgeHub(view: trailingIcon)
			badgeHub.moveCircleBy(xPos: -10, yPos: 5)
			badgeHub.setCountLabelFont(.systemFont(ofSize: 16))
			badgeHub.setCount(UserDefaults.zendeskChatNotificationCount)
		}
	}
}
