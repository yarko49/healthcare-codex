//
//  LinkCell.swift
//  Allie
//
//  Created by Onseen on 2/8/22.
//

import CareKitStore
import CareKitUI
import CareModel
import MessageKit
import UIKit

protocol LinkCellDelegate: AnyObject {
	func onClickLinkItem(linkItem: CHLink)
}

class LinkCell: UICollectionViewCell {
	static let cellID: String = "LinkCell"

	var timelineViewModel: TimelineItemViewModel!

	private var container: UIView = {
		let container = UIView()
		container.translatesAutoresizingMaskIntoConstraints = false
		container.backgroundColor = .white
		container.layer.cornerRadius = 8.0
		return container
	}()

	private var headerStackView: UIStackView = {
		let headerStackView = UIStackView()
		headerStackView.translatesAutoresizingMaskIntoConstraints = false
		headerStackView.axis = .vertical
		headerStackView.alignment = .leading
		headerStackView.distribution = .fill
		headerStackView.spacing = 4.0
		return headerStackView
	}()

	private var title: UILabel = {
		let title = UILabel()
		title.translatesAutoresizingMaskIntoConstraints = false
		title.font = .systemFont(ofSize: 18, weight: .bold)
		title.numberOfLines = 0
		title.lineBreakMode = .byWordWrapping
		title.textColor = .black
		return title
	}()

	private var subTitle: UILabel = {
		let subTitle = UILabel()
		subTitle.translatesAutoresizingMaskIntoConstraints = false
		subTitle.font = .systemFont(ofSize: 14)
		subTitle.numberOfLines = 0
		subTitle.lineBreakMode = .byWordWrapping
		subTitle.textColor = .mainGray
		return subTitle
	}()

	private var divider: UIView = {
		let divider = UIView()
		divider.translatesAutoresizingMaskIntoConstraints = false
		divider.backgroundColor = .lightGrey
		return divider
	}()

	private var footerStackView: UIStackView = {
		let footerStackView = UIStackView()
		footerStackView.translatesAutoresizingMaskIntoConstraints = false
		footerStackView.axis = .vertical
		footerStackView.alignment = .leading
		footerStackView.distribution = .fill
		footerStackView.spacing = 4.0
		return footerStackView
	}()

	weak var delegate: LinkCellDelegate?

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
		container.backgroundColor = .clear
	}

	private func setupViews() {
		backgroundColor = .clear
		contentView.addSubview(container)
		[headerStackView, footerStackView].forEach { container.addSubview($0) }
		[title, subTitle, divider].forEach { headerStackView.addArrangedSubview($0) }

		container.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
		container.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
		container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5.0).isActive = true
		container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10.0).isActive = true

		headerStackView.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
		headerStackView.topAnchor.constraint(equalTo: container.topAnchor, constant: 24).isActive = true
		headerStackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20).isActive = true

		footerStackView.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
		footerStackView.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: 12).isActive = true
		footerStackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20).isActive = true
		let bottomAnchor = footerStackView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -24.0)
		bottomAnchor.priority = .defaultLow
		bottomAnchor.isActive = true
		divider.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
		divider.widthAnchor.constraint(equalTo: headerStackView.widthAnchor, multiplier: 1.0).isActive = true
	}

	func configureCell(timelineItemViewModel: TimelineItemViewModel) {
		timelineViewModel = timelineItemViewModel
		container.backgroundColor = timelineItemViewModel.cellType == .current ? .white : .clear
		if let titleText = timelineItemViewModel.timelineItemModel.event.task.title {
			title.text = titleText
		} else {
			title.isHidden = true
		}
		if let subTitleText = timelineItemViewModel.timelineItemModel.event.task.instructions {
			subTitle.text = subTitleText
		} else {
			subTitle.isHidden = true
		}
		if let task = timelineItemViewModel.timelineItemModel.event.task as? OCKTask, let chLinkItems = task.links, !chLinkItems.isEmpty {
			for (index, chLinkItem) in chLinkItems.enumerated() {
				let linkItemView = UIView()
				linkItemView.backgroundColor = .clear
				linkItemView.layer.cornerRadius = 4.0
				let linkTitle = UILabel()
				linkTitle.textColor = .darkGray
				linkTitle.font = .systemFont(ofSize: 14)
				linkTitle.numberOfLines = 1
				let linkImage = UIImageView()
				linkImage.tintColor = .darkGray
				let actionButton = UIButton()
				actionButton.backgroundColor = .clear
				actionButton.setTitle("", for: .normal)
				actionButton.tag = index
				[linkItemView, linkTitle, linkImage, actionButton].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
				footerStackView.addArrangedSubview(linkItemView)
				linkItemView.widthAnchor.constraint(equalTo: footerStackView.widthAnchor, multiplier: 1.0).isActive = true
				[linkTitle, linkImage, actionButton].forEach { linkItemView.addSubview($0) }

				let topAnchor = linkImage.topAnchor.constraint(equalTo: linkItemView.topAnchor, constant: 6)
				topAnchor.priority = .defaultLow
				topAnchor.isActive = true
				linkImage.centerYAnchor.constraint(equalTo: linkItemView.centerYAnchor).isActive = true
				linkImage.trailingAnchor.constraint(equalTo: linkItemView.trailingAnchor, constant: -6).isActive = true
				linkImage.heightAnchor.constraint(equalToConstant: 24).isActive = true
				linkImage.widthAnchor.constraint(equalToConstant: 24).isActive = true

				linkTitle.centerYAnchor.constraint(equalTo: linkImage.centerYAnchor).isActive = true
				linkTitle.leadingAnchor.constraint(equalTo: linkItemView.leadingAnchor, constant: 6).isActive = true
				linkTitle.trailingAnchor.constraint(equalTo: linkImage.leadingAnchor, constant: 6).isActive = true

				actionButton.centerXAnchor.constraint(equalTo: linkItemView.centerXAnchor).isActive = true
				actionButton.centerYAnchor.constraint(equalTo: linkItemView.centerYAnchor).isActive = true
				actionButton.leadingAnchor.constraint(equalTo: linkItemView.leadingAnchor).isActive = true
				actionButton.topAnchor.constraint(equalTo: linkItemView.topAnchor).isActive = true
				actionButton.addTarget(self, action: #selector(onClickLinkItem), for: .touchUpInside)

				linkTitle.text = chLinkItem.title
				let iconConfig = UIImage.SymbolConfiguration(pointSize: 26.0)
				if let linkItemData = chLinkItem.linkItemData {
					linkImage.image = UIImage(systemName: linkItemData.iconSymbol, withConfiguration: iconConfig)
				} else {
					linkImage.image = UIImage(named: "icon-empty")
				}
//				switch chLinkItem.linkItem {
//				case .appStore:
//					linkImage.image = UIImage(systemName: LinkSymbols.appStore)
//				case .url(_, _, let symbol):
//					linkImage.image = UIImage(systemName: symbol)
//				case .website:
//					linkImage.image = UIImage(systemName: LinkSymbols.website)
//				case .location:
//					linkImage.image = UIImage(systemName: LinkSymbols.address)
//				case .call:
//					linkImage.image = UIImage(systemName: LinkSymbols.call)
//				case .message:
//					linkImage.image = UIImage(systemName: LinkSymbols.message)
//				case .email:
//					linkImage.image = UIImage(systemName: LinkSymbols.email)
//				case .none:
//					break
//				}
			}
		} else {
			footerStackView.isHidden = true
		}
	}

	@objc func onClickLinkItem(sender: UIButton) {
		if let task = timelineViewModel.timelineItemModel.event.task as? OCKTask, let linkItems = task.links, !linkItems.isEmpty {
			let index = sender.tag
			let linkItem = linkItems[index]
			delegate?.onClickLinkItem(linkItem: linkItem)
		} else {
			return
		}
	}
}
