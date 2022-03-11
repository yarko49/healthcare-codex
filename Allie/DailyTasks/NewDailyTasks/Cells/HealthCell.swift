//
//  HealthCell.swift
//  Allie
//
//  Created by Onseen 2/13/22.
//

import CareKit
import CareKitStore
import UIKit

protocol HealthCellDelegate: AnyObject {
	func onCellClickForActive(cellIndex: Int)
	func onAddTaskData(timelineViewModel: TimelineItemViewModel)
	func onUpdateTaskData(timelineViewModel: TimelineItemViewModel)
	func onCheckTaskData(timelineViewModel: TimelineItemViewModel)
}

class HealthCell: UICollectionViewCell {
	static let cellID: String = "HealthCell"

	weak var delegate: HealthCellDelegate?
	private var timelineViewModel: TimelineItemViewModel!
	private var cellIndex: Int!

	private var container: UIView = {
		let container = UIView()
		container.translatesAutoresizingMaskIntoConstraints = false
		container.backgroundColor = .clear
		container.layer.cornerRadius = 8.0
		return container
	}()

	private var subContainer: UIView = {
		let subContainer = UIView()
		subContainer.translatesAutoresizingMaskIntoConstraints = false
		subContainer.layer.cornerRadius = 8.0
		return subContainer
	}()

	private var stepStack: UIStackView = {
		let stepStack = UIStackView()
		stepStack.translatesAutoresizingMaskIntoConstraints = false
		stepStack.axis = .vertical
		stepStack.alignment = .center
		stepStack.distribution = .equalSpacing
		stepStack.spacing = 0
		return stepStack
	}()

	private var topDash: UIView = {
		let dash = UIView()
		dash.translatesAutoresizingMaskIntoConstraints = false
		return dash
	}()

	private var bottomDash: UIView = {
		let dash = UIView()
		dash.translatesAutoresizingMaskIntoConstraints = false
		return dash
	}()

	private var icon: UIImageView = {
		let icon = UIImageView()
		icon.translatesAutoresizingMaskIntoConstraints = false
		icon.layer.cornerRadius = 14.0
		icon.clipsToBounds = true
		return icon
	}()

	private var contentStack: UIStackView = {
		let contentStack = UIStackView()
		contentStack.translatesAutoresizingMaskIntoConstraints = false
		contentStack.spacing = 6
		contentStack.axis = .vertical
		contentStack.alignment = .leading
		contentStack.distribution = .fill
		return contentStack
	}()

	private var title: UILabel = {
		let title = UILabel()
		title.translatesAutoresizingMaskIntoConstraints = false
		title.numberOfLines = 0
		title.lineBreakMode = .byWordWrapping
		return title
	}()

	private let subTitle: UILabel = {
		let subTitle = UILabel()
		subTitle.translatesAutoresizingMaskIntoConstraints = false
		subTitle.numberOfLines = 0
		subTitle.lineBreakMode = .byWordWrapping
		return subTitle
	}()

	private var trailingButton: UIButton = {
		let trailingButton = UIButton()
		trailingButton.translatesAutoresizingMaskIntoConstraints = false
		trailingButton.layer.cornerRadius = 22
		trailingButton.layer.borderWidth = 1
		trailingButton.layer.borderColor = UIColor.black.cgColor
		return trailingButton
	}()

	private let actionButton: UIButton = {
		let actionButton = UIButton()
		actionButton.translatesAutoresizingMaskIntoConstraints = false
		actionButton.backgroundColor = .clear
		actionButton.setTitle("", for: .normal)
		return actionButton
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupViews()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupViews() {
		contentView.backgroundColor = .clear
		contentView.addSubview(container)
		[subContainer, stepStack].forEach { container.addSubview($0) }
		[contentStack, trailingButton, actionButton].forEach { subContainer.addSubview($0) }
		[topDash, icon, bottomDash].forEach { stepStack.addArrangedSubview($0) }
		[title, subTitle].forEach { contentStack.addArrangedSubview($0) }

		container.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
		container.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
		container.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
		container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true

		stepStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 0).isActive = true
		stepStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 0).isActive = true
		stepStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20).isActive = true
		topDash.widthAnchor.constraint(equalToConstant: 1.0).isActive = true
		let topHeightAnchor = topDash.heightAnchor.constraint(equalToConstant: 30)
		topHeightAnchor.priority = UILayoutPriority(999)
		topHeightAnchor.isActive = true
		icon.widthAnchor.constraint(equalToConstant: 28.0).isActive = true
		icon.heightAnchor.constraint(equalToConstant: 28.0).isActive = true
		bottomDash.widthAnchor.constraint(equalToConstant: 1.0).isActive = true
		let bottomHeightAnchor = bottomDash.heightAnchor.constraint(equalToConstant: 30)
		bottomHeightAnchor.priority = UILayoutPriority(999)
		bottomHeightAnchor.isActive = true

		subContainer.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
		subContainer.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
		subContainer.topAnchor.constraint(equalTo: container.topAnchor, constant: 5).isActive = true
		subContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true

		trailingButton.centerYAnchor.constraint(equalTo: subContainer.centerYAnchor).isActive = true
		trailingButton.trailingAnchor.constraint(equalTo: subContainer.trailingAnchor, constant: -20.0).isActive = true
		trailingButton.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
		trailingButton.widthAnchor.constraint(equalToConstant: 44.0).isActive = true

		contentStack.centerYAnchor.constraint(equalTo: subContainer.centerYAnchor).isActive = true
		contentStack.leadingAnchor.constraint(equalTo: subContainer.leadingAnchor, constant: 68.0).isActive = true
		contentStack.trailingAnchor.constraint(equalTo: trailingButton.leadingAnchor, constant: -12).isActive = true

		actionButton.centerXAnchor.constraint(equalTo: subContainer.centerXAnchor).isActive = true
		actionButton.centerYAnchor.constraint(equalTo: subContainer.centerYAnchor).isActive = true
		actionButton.leadingAnchor.constraint(equalTo: subContainer.leadingAnchor).isActive = true
		actionButton.topAnchor.constraint(equalTo: subContainer.topAnchor).isActive = true
		actionButton.addTarget(self, action: #selector(onTaskCellClick), for: .touchUpInside)
	}

	func configureCell(item: TimelineItemViewModel, cellIndex: Int) {
		timelineViewModel = item
		self.cellIndex = cellIndex
		let ockEvent = item.timelineItemModel.event
		let groupIdentifierType = ockEvent.task.groupIdentifierType

		if item.cellType == .current {
			subContainer.backgroundColor = .white
			subContainer.setShadow(opacity: 0.1)
			topDash.backgroundColor = .clear
			bottomDash.backgroundColor = .clear
			trailingButton.isHidden = false
		} else {
			subContainer.backgroundColor = .clear
			subContainer.clearShadow()
			topDash.backgroundColor = .mainGray
			bottomDash.backgroundColor = .mainGray
			trailingButton.isHidden = true
		}
		if item.tapCount == 0 {
			subContainer.backgroundColor = .clear
			subContainer.clearShadow()
			trailingButton.isHidden = true
			topDash.backgroundColor = .mainGray
			bottomDash.backgroundColor = .mainGray
		} else if item.tapCount == 1 {
			subContainer.backgroundColor = .white
			subContainer.setShadow(opacity: 0.1)
			topDash.backgroundColor = .clear
			bottomDash.backgroundColor = .clear
			trailingButton.isHidden = false
			if groupIdentifierType == .symptoms || groupIdentifierType == .labeledValue {
				trailingButton.backgroundColor = .black
				trailingButton.tintColor = .white
				if item.cellType == .completed {
					trailingButton.setImage(UIImage(systemName: "pencil"), for: .normal)
				} else {
					trailingButton.setImage(UIImage(systemName: "plus"), for: .normal)
				}
			} else if groupIdentifierType == .simple || groupIdentifierType == .grid {
				if item.cellType == .completed {
					trailingButton.backgroundColor = .black
					trailingButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
				} else {
					trailingButton.backgroundColor = .clear
					trailingButton.setImage(nil, for: .normal)
				}
			}
		}
		title.attributedText = item.timelineItemModel.event.task.title?.attributedString(style: .silkabold20, foregroundColor: .black)
		let quantityIdentifier = (ockEvent.task as? OCKHealthKitTask)?.healthKitLinkage.quantityIdentifier
		if let dataType = quantityIdentifier?.dataType {
			icon.image = dataType.image
		} else if let identifier = ockEvent.task.groupIdentifierType, let iconImage = identifier.icon {
			icon.image = iconImage
		} else {
			icon.image = UIImage(named: "icon-empty")
		}
		if groupIdentifierType == .symptoms || groupIdentifierType == .labeledValue {
			if item.cellType == .completed {
				let linkPage = (ockEvent.task as? OCKHealthKitTask)?.healthKitLinkage
				let outComes = item.timelineItemModel.outcomeValues!
				let date = outComes.first!.createdDate
				let dateString = ScheduleUtility.timeFormatter.string(from: date)
				var formattedValue = outComes.first?.formattedValue
				var context: String?
				if linkPage?.quantityIdentifier == .bloodPressureDiastolic {
					let systolicValue: OCKOutcomeValue = outComes[0]
					let diastolicValue: OCKOutcomeValue = outComes[1]
					context = systolicValue.symptomTitle
					formattedValue = String(format: "%d/%d", systolicValue.integerValue ?? 0, diastolicValue.integerValue ?? 0)
				}
				if linkPage?.quantityIdentifier == .insulinDelivery {
					context = outComes.first?.insulinReasonTitle
				} else if linkPage?.quantityIdentifier == .bloodGlucose {
					context = outComes.first?.bloodGlucoseMealTimeTitle
				} else {
					context = outComes.first?.symptomTitle
				}
				if let contextValue = context, !contextValue.replacingOccurrences(of: " ", with: "").isEmpty {
					if let formattedVal = formattedValue, !formattedVal.isEmpty {
						subTitle.attributedText = "\(dateString), \(formattedVal), \(contextValue)".attributedString(style: .silkaregular16, foregroundColor: UIColor.black.withAlphaComponent(0.5))
					} else {
						subTitle.attributedText = "\(dateString), \(contextValue)".attributedString(style: .silkaregular16, foregroundColor: UIColor.black.withAlphaComponent(0.5))
					}
				} else {
					if let formattedVal = formattedValue, !formattedVal.isEmpty {
						subTitle.attributedText = "\(dateString), \(formattedVal)".attributedString(style: .silkaregular16, foregroundColor: UIColor.black.withAlphaComponent(0.5))
					} else {
						subTitle.attributedText = "\(dateString)".attributedString(style: .silkaregular16, foregroundColor: UIColor.black.withAlphaComponent(0.5))
					}
				}
			} else {
				subTitle.attributedText = (ockEvent.task.instructions ?? "").attributedString(style: .silkaregular16, foregroundColor: UIColor.black.withAlphaComponent(0.5))
			}
		} else if groupIdentifierType == .simple || groupIdentifierType == .grid {
			if groupIdentifierType == .simple {
				subTitle.attributedText = (ockEvent.task.instructions ?? ScheduleUtility.scheduleLabel(for: ockEvent))?.attributedString(style: .silkaregular16, foregroundColor: UIColor.black.withAlphaComponent(0.5))
			} else {
				let isCompleted = ockEvent.outcome != nil
				subTitle.attributedText = (isCompleted ? ScheduleUtility.completedTimeLabel(for: ockEvent) : ScheduleUtility.timeLabel(for: ockEvent, includesEnd: false))?.attributedString(style: .silkaregular16, foregroundColor: UIColor.black.withAlphaComponent(0.5))
			}
		}
	}

	@objc func onTaskCellClick() {
		if timelineViewModel.tapCount == 0 {
			delegate?.onCellClickForActive(cellIndex: cellIndex)
		} else if timelineViewModel.tapCount == 1 {
			let task = timelineViewModel.timelineItemModel.event.task
			let groupIdentifierType = task.groupIdentifierType
			if groupIdentifierType == .symptoms || groupIdentifierType == .labeledValue {
				if timelineViewModel.cellType == .completed {
					delegate?.onUpdateTaskData(timelineViewModel: timelineViewModel)
				} else {
					delegate?.onAddTaskData(timelineViewModel: timelineViewModel)
				}
			} else if groupIdentifierType == .simple || groupIdentifierType == .grid {
				delegate?.onCheckTaskData(timelineViewModel: timelineViewModel)
			}
		}
	}
}
