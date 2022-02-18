//
//  SettingsModel.swift
//  Allie
//

import Foundation
import UIKit

enum SettingsType: CustomStringConvertible, CaseIterable, Hashable {
	case accountDetails
	case myDevices
	case notifications
	case systemAuthorization
	case feedback
	case privacyPolicy
	case termsOfService
	case support
	case troubleShoot
	case providers
	case readings
	case logging

	var title: String {
		switch self {
		case .accountDetails:
			return String.accountDetails
		case .myDevices:
			return NSLocalizedString("CONNECTED_DEVICES", comment: "Connected Devices")
		case .notifications:
			return String.notifications
		case .systemAuthorization:
			return String.systemAuthorization
		case .feedback:
			return String.feedback
		case .troubleShoot:
			return String.troubleShoot
		case .support:
			return String.support
		case .privacyPolicy:
			return String.privacyPolicy
		case .termsOfService:
			return String.termsOfService
		case .providers:
			return NSLocalizedString("HEALTHCARE_PROVIDERS", comment: "Health Providers")
		case .readings:
			return "Readings"
		case .logging:
			return "File Logging"
		}
	}

	var description: String {
		title
	}
}

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
		trailingIcon.tintColor = .allieBlack
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
//		if type == .feedback {
//			accessoryType = .disclosureIndicator
//			let zendBadgeCount = UserDefaults.zendeskChatNotificationCount
//			if zendBadgeCount == 0 {
//				accessoryView = nil
//			} else {
//				setTableViewCellBadge(badgeCount: zendBadgeCount)
//			}
//		} else {
//			accessoryType = .disclosureIndicator
//			accessoryView = nil
//		}
	}
}
