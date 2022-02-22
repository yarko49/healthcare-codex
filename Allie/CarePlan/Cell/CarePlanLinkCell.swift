//
//  CarePlanLinkCell.swift
//  Allie
//
//  Created by Onseen on 2/21/22.
//

import CareKitStore
import UIKit

class CarePlanLinkCell: UICollectionViewCell {
	static let cellID: String = "CarePlanLinkCell"

	private var container: UIView = {
		let container = UIView()
		container.translatesAutoresizingMaskIntoConstraints = false
		container.backgroundColor = .white
		container.layer.cornerRadius = 8.0
		container.setShadow()
		return container
	}()

	private var footerStackView: UIStackView = {
		let footerStackView = UIStackView()
		footerStackView.translatesAutoresizingMaskIntoConstraints = false
		footerStackView.axis = .vertical
		footerStackView.alignment = .leading
		footerStackView.distribution = .fill
		footerStackView.spacing = 10.0
		return footerStackView
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupViews()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		footerStackView.arrangedSubviews.forEach {
			$0.subviews.forEach { subItem in
				subItem.removeFromSuperview()
			}
			footerStackView.removeArrangedSubview($0)
		}
	}

	private func setupViews() {
		backgroundColor = .clear
		contentView.backgroundColor = .clear
		contentView.addSubview(container)
		container.addSubview(footerStackView)

		container.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
		container.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
		container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5.0).isActive = true
		container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0).isActive = true

		footerStackView.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
		footerStackView.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
		footerStackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20.0).isActive = true
		let topAnchor = footerStackView.topAnchor.constraint(equalTo: container.topAnchor, constant: 20.0)
		topAnchor.priority = .defaultLow
		topAnchor.isActive = true
	}

	func configureCell(task: CHTasks) {
		if let firstTask = task.first {
			if let linkItems = firstTask.links, !linkItems.isEmpty {
				linkItems.forEach { linkItem in
					let linkItemView = UIStackView()
					linkItemView.translatesAutoresizingMaskIntoConstraints = false
					linkItemView.axis = .horizontal
					linkItemView.alignment = .center
					linkItemView.distribution = .fill
					linkItemView.spacing = 10.0

					if !linkItemView.arrangedSubviews.isEmpty {
						linkItemView.arrangedSubviews.forEach { linkItemView.removeArrangedSubview($0) }
					}

					let icon = UIImageView()
					icon.translatesAutoresizingMaskIntoConstraints = false
					icon.layer.cornerRadius = 13.0
					icon.contentMode = .scaleToFill
					icon.clipsToBounds = true
					icon.tintColor = .allieGray

					let linkTitle = UILabel()
					linkTitle.translatesAutoresizingMaskIntoConstraints = false
					linkTitle.numberOfLines = 0
					linkTitle.lineBreakMode = .byWordWrapping

					let typeButton = UIButton()
					typeButton.translatesAutoresizingMaskIntoConstraints = false
					typeButton.contentHorizontalAlignment = .right

					[icon, linkTitle, typeButton].forEach { linkItemView.addArrangedSubview($0) }
					icon.widthAnchor.constraint(equalToConstant: 26.0).isActive = true
					icon.heightAnchor.constraint(equalToConstant: 26.0).isActive = true

					footerStackView.addArrangedSubview(linkItemView)

					linkItemView.widthAnchor.constraint(equalTo: footerStackView.widthAnchor).isActive = true

					linkTitle.attributedText = linkItem.title.attributedString(style: .bold16, foregroundColor: .allieBlack, letterSpacing: -0.41)
					typeButton.setAttributedTitle(linkItem.type.rawValue.capitalized.attributedString(style: .regular13, foregroundColor: .allieGray, letterSpacing: -0.025), for: .normal)
					let iconConfig = UIImage.SymbolConfiguration(pointSize: 26.0)
					switch linkItem.linkItem {
					case .appStore:
						icon.image = UIImage(systemName: LinkSymbols.appStore, withConfiguration: iconConfig)
					case .url(_, title: _, let symbol):
						icon.image = UIImage(systemName: symbol, withConfiguration: iconConfig)
					case .website(_, title: _):
						icon.image = UIImage(systemName: LinkSymbols.website, withConfiguration: iconConfig)
					case .location(_, _, title: _):
						icon.image = UIImage(systemName: LinkSymbols.address, withConfiguration: iconConfig)
					case .call(phoneNumber: _, title: _):
						icon.image = UIImage(systemName: LinkSymbols.call, withConfiguration: iconConfig)
					case .message(phoneNumber: _, title: _):
						icon.image = UIImage(systemName: LinkSymbols.message, withConfiguration: iconConfig)
					case .email(recipient: _, title: _):
						icon.image = UIImage(systemName: LinkSymbols.email, withConfiguration: iconConfig)
					case .none:
						icon.image = UIImage(named: "icon-empty")
					}
				}
			}
		}
	}
}
