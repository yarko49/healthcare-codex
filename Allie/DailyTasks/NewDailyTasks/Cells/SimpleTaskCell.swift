//
//  SimpleTaskCell.swift
//  Allie
//
//  Created by Onseen on 2/8/22.
//

import UIKit

class SimpleTaskCell: UICollectionViewCell {
	static let cellID: String = "SimpleTaskCell"
	var timelineViewModel: TimelineItemViewModel!

	private var container: UIView = {
		let container = UIView()
		container.translatesAutoresizingMaskIntoConstraints = false
		container.backgroundColor = .white
		container.layer.cornerRadius = 8.0
		return container
	}()

	private let contentStackView: UIStackView = {
		let contentStackView = UIStackView()
		contentStackView.translatesAutoresizingMaskIntoConstraints = false
		contentStackView.axis = .vertical
		contentStackView.alignment = .leading
		contentStackView.distribution = .fill
		contentStackView.spacing = 4.0
		return contentStackView
	}()

	private let title: UILabel = {
		let title = UILabel()
		title.translatesAutoresizingMaskIntoConstraints = false
		title.textColor = .black
		title.numberOfLines = 0
		title.lineBreakMode = .byWordWrapping
		title.font = .systemFont(ofSize: 18, weight: .bold)
		return title
	}()

	private let subTitle: UILabel = {
		let subTitle = UILabel()
		subTitle.translatesAutoresizingMaskIntoConstraints = false
		subTitle.numberOfLines = 0
		subTitle.lineBreakMode = .byWordWrapping
		subTitle.textColor = .mainLightGray
		subTitle.font = .systemFont(ofSize: 14)
		return subTitle
	}()

	private let completionButton: UIButton = {
		let completionButton = UIButton()
		completionButton.translatesAutoresizingMaskIntoConstraints = false
		completionButton.setTitle("", for: .normal)
		completionButton.layer.cornerRadius = 22.0
		completionButton.tintColor = .mainGray
		return completionButton
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
		container.backgroundColor = .clear
	}

	private func setupViews() {
		backgroundColor = .clear
		contentView.addSubview(container)
		[contentStackView, completionButton].forEach { container.addSubview($0) }
		[title, subTitle].forEach { contentStackView.addArrangedSubview($0) }

		container.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
		container.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
		container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5.0).isActive = true
		container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10.0).isActive = true

		completionButton.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
		completionButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20.0).isActive = true
		completionButton.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
		completionButton.widthAnchor.constraint(equalToConstant: 44.0).isActive = true
		completionButton.setBackgroundImage(UIImage(systemName: "circle"), for: .normal)

		contentStackView.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
		contentStackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20.0).isActive = true
		contentStackView.trailingAnchor.constraint(equalTo: completionButton.leadingAnchor, constant: 20.0).isActive = true
		let topAnchor = contentStackView.topAnchor.constraint(equalTo: container.topAnchor, constant: 24.0)
		topAnchor.priority = .defaultLow
		topAnchor.isActive = true
	}

	func configureCell(timelineItemViewModel: TimelineItemViewModel) {
		timelineViewModel = timelineItemViewModel
		container.backgroundColor = timelineItemViewModel.cellType == .current ? .white : .clear
		title.text = timelineItemViewModel.timelineItemModel.event.task.title ?? ""
		if let schedule = timelineItemViewModel.timelineItemModel.event.task.schedule.elements.first {
			subTitle.text = schedule.text ?? ""
		} else {
			subTitle.text = ""
		}
	}
}
