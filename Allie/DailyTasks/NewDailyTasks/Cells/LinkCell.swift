//
//  LinkCell.swift
//  Allie
//
//  Created by Onseen on 2/8/22.
//

import UIKit
import CareKitStore
import CareKitUI

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

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        footerStackView.arrangedSubviews.forEach { footerStackView.removeArrangedSubview($0) }
    }

    private func setupViews() {
        self.backgroundColor = .clear
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
        self.timelineViewModel = timelineItemViewModel
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
        if let task = timelineItemViewModel.timelineItemModel.event.task as? OCKTask, let linkItems = task.linkItems, !linkItems.isEmpty {
            linkItems.forEach({ linkItem in
                let linkItemView = UIView()
                linkItemView.backgroundColor = .lightGrey
                linkItemView.layer.cornerRadius = 4.0
                let linkTitle = UILabel()
                linkTitle.textColor = .darkGray
                linkTitle.font = .systemFont(ofSize: 14)
                linkTitle.numberOfLines = 1
                let linkImage = UIImageView()
                linkImage.tintColor = .darkGray
                [linkItemView, linkTitle, linkImage].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
                footerStackView.addArrangedSubview(linkItemView)
                linkItemView.widthAnchor.constraint(equalTo: footerStackView.widthAnchor, multiplier: 1.0).isActive = true
                [linkTitle, linkImage].forEach { linkItemView.addSubview($0) }

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

                switch linkItem {
                case .appStore(_, let title):
                    linkTitle.text = title
                    linkImage.image = UIImage(systemName: LinkSymbols.appStore)
                case .url(_, title: let title, let symbol):
                    linkTitle.text = title
                    linkImage.image = UIImage(systemName: symbol)
                case .website(_, title: let title):
                    linkTitle.text = title
                    linkImage.image = UIImage(systemName: LinkSymbols.website)
                case .location(_, _, title: let title):
                    linkTitle.text = title
                    linkImage.image = UIImage(systemName: LinkSymbols.address)
                case .call(phoneNumber: _, title: let title):
                    linkTitle.text = title
                    linkImage.image = UIImage(systemName: LinkSymbols.call)
                case .message(phoneNumber: _, title: let title):
                    linkTitle.text = title
                    linkImage.image = UIImage(systemName: LinkSymbols.message)
                case .email(recipient: _, title: let title):
                    linkTitle.text = title
                    linkImage.image = UIImage(systemName: LinkSymbols.email)
                }
            })
        } else {
            footerStackView.isHidden = true
        }
    }
}

struct LinkSymbols {
    static let call = "phone.circle.fill"
    static let website = "safari.fill"
    static let email = "envelope.circle.fill"
    static let message = "message.circle.fill"
    static let appStore = "arrow.up.right.circle.fill"
    static let address = "location.circle.fill"
}
