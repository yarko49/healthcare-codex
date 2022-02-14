//
//  GridTaskCell.swift
//  Allie
//
//  Created by Onseen on 2/9/22.
//

import UIKit
import CareKitStore

class GridTaskCell: UICollectionViewCell {
    static let cellID: String = "GridTaskCell"
    var timelineViewModel: TimelineItemViewModel!

    private var container: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .white
        container.layer.cornerRadius = 8.0
        return container
    }()

    private var topStackView: UIStackView = {
        let topStackView = UIStackView()
        topStackView.translatesAutoresizingMaskIntoConstraints = false
        topStackView.spacing = 6
        topStackView.axis = .vertical
        topStackView.alignment = .leading
        topStackView.distribution = .fill
        return topStackView
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

    private let subTitle: UILabel = {
        let subTitle = UILabel()
        subTitle.translatesAutoresizingMaskIntoConstraints = false
        subTitle.font = .systemFont(ofSize: 14)
        subTitle.numberOfLines = 0
        subTitle.lineBreakMode = .byWordWrapping
        subTitle.textColor = .mainGray
        subTitle.text = "Events Remaining"
        return subTitle
    }()

    private var instruction: UILabel = {
        let instruction = UILabel()
        instruction.translatesAutoresizingMaskIntoConstraints = false
        instruction.font = .systemFont(ofSize: 14)
        instruction.numberOfLines = 0
        instruction.lineBreakMode = .byWordWrapping
        instruction.textColor = .mainLightGray
        return instruction
    }()

    private var divider: UIView = {
        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = .lightGrey
        return divider
    }()

    private var bottomStackView: UIStackView = {
        let bottomStackView = UIStackView()
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView.axis = .vertical
        bottomStackView.alignment = .leading
        bottomStackView.distribution = .fill
        bottomStackView.spacing = 20.0
        return bottomStackView
    }()

    private var contentStackView: UIStackView = {
        let contentStackView = UIStackView()
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .horizontal
        contentStackView.alignment = .center
        contentStackView.distribution = .equalSpacing
        contentStackView.spacing = 32
        return contentStackView
    }()

    private var contentScrollView: UIScrollView = {
        let contentScrollView = UIScrollView()
        contentScrollView.translatesAutoresizingMaskIntoConstraints = false
        contentScrollView.showsVerticalScrollIndicator = false
        contentScrollView.showsHorizontalScrollIndicator = false
        return contentScrollView
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
        contentStackView.arrangedSubviews.forEach { contentStackView.removeArrangedSubview($0) }
        container.backgroundColor = .clear
    }

    private func setupViews() {
        self.backgroundColor = .clear
        contentView.addSubview(container)
        [topStackView, bottomStackView].forEach { container.addSubview($0) }
        [title, subTitle, divider].forEach { topStackView.addArrangedSubview($0) }
        [contentScrollView, instruction].forEach { bottomStackView.addArrangedSubview($0) }
        contentScrollView.addSubview(contentStackView)

        container.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        container.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5.0).isActive = true
        container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10.0).isActive = true

        topStackView.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        topStackView.topAnchor.constraint(equalTo: container.topAnchor, constant: 24.0).isActive = true
        topStackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20.0).isActive = true

        bottomStackView.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        bottomStackView.topAnchor.constraint(equalTo: topStackView.bottomAnchor, constant: 24.0).isActive = true
        bottomStackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20.0).isActive = true
        let bottomAnchor = bottomStackView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -24.0)
        bottomAnchor.priority = .defaultLow
        bottomAnchor.isActive = true
        contentScrollView.widthAnchor.constraint(equalTo: bottomStackView.widthAnchor).isActive = true
        contentScrollView.heightAnchor.constraint(equalToConstant: 90.0).isActive = true

        divider.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        divider.widthAnchor.constraint(equalTo: topStackView.widthAnchor).isActive = true
        contentStackView.leadingAnchor.constraint(equalTo: contentScrollView.leadingAnchor).isActive = true
        contentStackView.topAnchor.constraint(equalTo: contentScrollView.topAnchor).isActive = true
        contentStackView.trailingAnchor.constraint(equalTo: contentScrollView.trailingAnchor).isActive = true
        contentStackView.bottomAnchor.constraint(equalTo: contentScrollView.bottomAnchor).isActive = true
    }

    func configureCell(timelineItemViewModel: TimelineItemViewModel) {
        self.timelineViewModel = timelineItemViewModel
        container.backgroundColor = timelineItemViewModel.cellType == .current ? .white : .clear
        if let titleValue = timelineViewModel.timelineItemModel.event.task.title {
            title.text = titleValue
        } else {
            title.isHidden = true
        }
        if let instrunctionValue = timelineItemViewModel.timelineItemModel.event.task.instructions {
            instruction.text = instrunctionValue
        } else {
            instruction.isHidden = true
        }
        let schedules: [OCKScheduleElement] = timelineViewModel.timelineItemModel.event.task.schedule.elements
        var contentWidth: CGFloat = 0
        schedules.forEach { schedule in
            let view = GridItemView(titleValue: schedule.text ?? "")
            view.translatesAutoresizingMaskIntoConstraints = false
            let titleWidth = view.title.intrinsicContentSize.width
            let itemWidth = titleWidth > 60 ? titleWidth : 60
            contentWidth += itemWidth
            contentStackView.addArrangedSubview(view)
        }
        let totalContentWidth = contentWidth + CGFloat((schedules.count - 1)) * contentStackView.spacing
        if totalContentWidth > contentScrollView.frame.width {
            contentScrollView.contentInset = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 32)
        } else {
            let horizontalInset = (contentScrollView.frame.width - totalContentWidth) / 2
            contentScrollView.contentInset = UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
        }
    }
}

class GridItemView: UIView {

    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .mainLightGray
        imageView.image = UIImage(systemName: "circle")
        return imageView
    }()

    var title: UILabel = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.textColor = .mainLightGray
        title.font = .systemFont(ofSize: 14)
        return title
    }()

    private var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 6.0
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    convenience init(titleValue: String) {
        self.init(frame: .zero)
        self.title.text = titleValue
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupViews() {
        self.backgroundColor = .clear
        addSubview(stackView)
        [imageView, title].forEach { stackView.addArrangedSubview($0) }
        stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
}
