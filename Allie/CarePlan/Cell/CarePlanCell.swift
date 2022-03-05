//
//  CarePlanCell.swift
//  Allie
//
//  Created by Onseen on 2/21/22.
//

import CareModel
import UIKit

class CarePlanCell: UICollectionViewCell {
	static let cellID: String = "CarePlanCell"

	private var container: UIView = {
		let container = UIView()
		container.translatesAutoresizingMaskIntoConstraints = false
		container.backgroundColor = .white
		container.layer.cornerRadius = 8.0
		container.setShadow()
		return container
	}()

	private var contentStackView: UIStackView = {
		let contentStackView = UIStackView()
		contentStackView.translatesAutoresizingMaskIntoConstraints = false
		contentStackView.axis = .vertical
		contentStackView.spacing = 16.0
		contentStackView.alignment = .leading
		contentStackView.distribution = .fill
		return contentStackView
	}()

	private var subContentStackView: UIStackView = {
		let subContentStackView = UIStackView()
		subContentStackView.translatesAutoresizingMaskIntoConstraints = false
		subContentStackView.alignment = .leading
		subContentStackView.axis = .vertical
		subContentStackView.distribution = .fill
		subContentStackView.spacing = 16.0
		return subContentStackView
	}()

	private var title: UILabel = {
		let title = UILabel()
		title.translatesAutoresizingMaskIntoConstraints = false
		title.numberOfLines = 0
		title.lineBreakMode = .byWordWrapping
		return title
	}()

	override func prepareForReuse() {
		super.prepareForReuse()
		subContentStackView.arrangedSubviews.forEach {
			$0.subviews.forEach { subView in
				subView.removeFromSuperview()
			}
			subContentStackView.removeArrangedSubview($0)
		}
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
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
		container.addSubview(contentStackView)
		[title, subContentStackView].forEach { contentStackView.addArrangedSubview($0) }

		container.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
		container.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
		container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0).isActive = true
		container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5.0).isActive = true

		contentStackView.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
		contentStackView.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
		contentStackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20.0).isActive = true
		contentStackView.topAnchor.constraint(equalTo: container.topAnchor, constant: 20.0).isActive = true
	}

	func configureCell(for task: CHTasks) {
		title.attributedText = task.first?.category?.capitalized.attributedString(style: .bold20, foregroundColor: UIColor.black, letterSpacing: -0.41)
		task.forEach { chTask in
			let taskItemView = UIStackView()
			taskItemView.translatesAutoresizingMaskIntoConstraints = false
			taskItemView.axis = .horizontal
			taskItemView.spacing = 10
			taskItemView.alignment = .top
			taskItemView.distribution = .fill

			if !taskItemView.arrangedSubviews.isEmpty {
				taskItemView.arrangedSubviews.forEach { taskItemView.removeArrangedSubview($0) }
			}

			let icon = UIImageView()
			icon.translatesAutoresizingMaskIntoConstraints = false
			icon.layer.cornerRadius = 13.0
			icon.layer.masksToBounds = true

			let textStackView = UIStackView()
			textStackView.translatesAutoresizingMaskIntoConstraints = false
			textStackView.axis = .vertical
			textStackView.spacing = 4.0
			textStackView.alignment = .leading
			textStackView.distribution = .fill

			if !textStackView.arrangedSubviews.isEmpty {
				textStackView.arrangedSubviews.forEach { textStackView.removeArrangedSubview($0) }
			}

			if let healthKitLink = chTask.healthKitLinkage, let iconImage = healthKitLink.quantityIdentifier.dataType?.image {
				icon.image = iconImage
			} else if let identifier = chTask.groupIdentifierType, let iconImage = identifier.icon {
				icon.image = iconImage
			} else {
				icon.image = UIImage(named: "icon-empty")
			}

			let taskTitle = UILabel()
			taskTitle.translatesAutoresizingMaskIntoConstraints = false
			taskTitle.numberOfLines = 0
			taskTitle.lineBreakMode = .byWordWrapping

			let instruction = UILabel()
			instruction.translatesAutoresizingMaskIntoConstraints = false
			instruction.numberOfLines = 0
			instruction.lineBreakMode = .byWordWrapping

			subContentStackView.addArrangedSubview(taskItemView)
			taskItemView.widthAnchor.constraint(equalTo: subContentStackView.widthAnchor).isActive = true

			[icon, textStackView].forEach { taskItemView.addArrangedSubview($0) }
			[taskTitle, instruction].forEach { textStackView.addArrangedSubview($0) }

			icon.heightAnchor.constraint(equalToConstant: 26.0).isActive = true
			icon.widthAnchor.constraint(equalToConstant: 26.0).isActive = true

			taskTitle.attributedText = chTask.title?.attributedString(style: .medium17, foregroundColor: UIColor.black, letterSpacing: 0.02)
			instruction.attributedText = chTask.instructions?.attributedString(style: .regular13, foregroundColor: .allieGray, letterSpacing: -0.03)
		}
	}
}
