//
//  NumericProgressCell.swift
//  Allie
//
//  Created by Onseen on 2/9/22.
//

import UIKit
import CareKitStore
import CareKit

class NumericProgressCell: UICollectionViewCell {
    static let cellID: String = "NumericProgressCell"
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

    private var subTitle: UILabel = {
        let subTitle = UILabel()
        subTitle.translatesAutoresizingMaskIntoConstraints = false
        subTitle.font = .systemFont(ofSize: 14)
        subTitle.numberOfLines = 0
        subTitle.lineBreakMode = .byWordWrapping
        subTitle.textColor = .mainGray
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
        contentStackView.distribution = .fillEqually
        return contentStackView
    }()

    private var progrssStackView: UIStackView = {
        let progressStackView = UIStackView()
        progressStackView.translatesAutoresizingMaskIntoConstraints = false
        progressStackView.axis = .vertical
        progressStackView.alignment = .center
        progressStackView.spacing = 6.0
        return progressStackView
    }()

    private var goalStackView: UIStackView = {
        let goalStackView = UIStackView()
        goalStackView.translatesAutoresizingMaskIntoConstraints = false
        goalStackView.axis = .vertical
        goalStackView.alignment = .center
        goalStackView.spacing = 6.0
        return goalStackView
    }()

    private var progressValueLable: UILabel = {
        let progressValueLabel = UILabel()
        progressValueLabel.translatesAutoresizingMaskIntoConstraints = false
        progressValueLabel.textColor = .brown
        progressValueLabel.textAlignment = .center
        progressValueLabel.font = .systemFont(ofSize: 20, weight: .bold)
        return progressValueLabel
    }()

    private let progressLable: UILabel = {
        let progressLabel = UILabel()
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.textColor = .brown
        progressLabel.textAlignment = .center
        progressLabel.font = .systemFont(ofSize: 20, weight: .bold)
        progressLabel.text = "PROGRESS"
        return progressLabel
    }()

    private var goalValueLable: UILabel = {
        let goalValueLabel = UILabel()
        goalValueLabel.translatesAutoresizingMaskIntoConstraints = false
        goalValueLabel.textColor = .mainGray
        goalValueLabel.textAlignment = .center
        goalValueLabel.font = .systemFont(ofSize: 20, weight: .bold)
        return goalValueLabel
    }()

    private let goalLable: UILabel = {
        let goalLabel = UILabel()
        goalLabel.translatesAutoresizingMaskIntoConstraints = false
        goalLabel.textColor = .mainGray
        goalLabel.textAlignment = .center
        goalLabel.font = .systemFont(ofSize: 20, weight: .bold)
        goalLabel.text = "GOAL"
        return goalLabel
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        self.backgroundColor = .clear
        contentView.addSubview(container)
        [topStackView, bottomStackView].forEach {container.addSubview($0) }
        [title, subTitle, divider].forEach { topStackView.addArrangedSubview($0) }
        [contentStackView, instruction].forEach { bottomStackView.addArrangedSubview($0) }
        [progrssStackView, goalStackView].forEach { contentStackView.addArrangedSubview($0) }
        [progressValueLable, progressLable].forEach { progrssStackView.addArrangedSubview($0) }
        [goalValueLable, goalLable].forEach {goalStackView.addArrangedSubview($0) }

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
        contentStackView.widthAnchor.constraint(equalTo: bottomStackView.widthAnchor).isActive = true

        divider.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        divider.widthAnchor.constraint(equalTo: topStackView.widthAnchor).isActive = true
    }

    func configureCell(timelineItemViewModel: TimelineItemViewModel) {
        self.timelineViewModel = timelineItemViewModel
        if let titleValue = timelineViewModel.timelineItemModel.event.task.title {
            title.text = titleValue
        } else {
            title.isHidden = true
        }
        if let subTitleValue = timelineViewModel.timelineItemModel.event.scheduleEvent.element.text {
            subTitle.text = subTitleValue
        } else {
            subTitle.isHidden = true
        }
        if let instrunctionValue = timelineItemViewModel.timelineItemModel.event.task.instructions {
            instruction.text = instrunctionValue
        } else {
            instruction.isHidden = true
        }
        let goalValue = timelineViewModel.timelineItemModel.event.scheduleEvent.element.targetValues.first?.numberValue?
            .doubleValue ?? 0
        let progressValue = timelineViewModel.timelineItemModel.event.outcome?.values.first?.numberValue?.doubleValue ?? 0
        let goal = goalValue.removingExtraneousDecimal() ?? "0"
        let progress = progressValue.removingExtraneousDecimal() ?? "0"
        goalValueLable.text = goal
        progressValueLable.text = progress
    }
}
