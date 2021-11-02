//
//  TaskView.swift
//  Allie
//
//  Created by Waqar Malik on 10/26/21.
//

import CareKitStore
import CareKitUI
import UIKit

struct CardBuilder: OCKCardable {
	let cardView: UIView
	let contentView: UIView
}

class TaskView: OCKView, OCKTaskDisplayable {
	weak var delegate: OCKTaskViewDelegate?

	let logItemsStackView: OCKStackView = {
		var view = OCKStackView()
		view.axis = .vertical
		return view
	}()

	let headerView: TaskHeaderView = {
		let view = TaskHeaderView(frame: .zero)
		view.button.setImage(UIImage(systemName: "plus"), for: .normal)
		view.button.backgroundColor = .allieGray
		view.textLabel.font = UIFont.systemFont(ofSize: 16.0, weight: .bold)
		view.textLabel.textColor = .allieGray
		view.detailTextLabel.text = NSLocalizedString("INSTRUCTIONS", comment: "Instructions")
		view.imageView.image = UIImage(named: "icon-insulin")
		view.heightAnchor.constraint(equalToConstant: TaskHeaderView.height).isActive = true
		return view
	}()

	lazy var headerButton = {
		OCKAnimatedButton(contentView: headerView, highlightOptions: [.defaultDelayOnSelect, .defaultOverlay], handlesSelection: false)
	}()

	let contentView: OCKView = {
		let view = OCKView()
		view.clipsToBounds = true
		return view
	}()

	override init() {
		super.init(frame: .zero)
		setup()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func setup() {
		preservesSuperviewLayoutMargins = true
		styleDidChange()
		addSubviews()
		constrainSubviews()
		setupGestures()
	}

	func addSubviews() {
		addSubview(contentView)
		contentView.addSubview(headerView)
		contentView.addSubview(logItemsStackView)
	}

	func constrainSubviews() {
		[contentView, headerView, logItemsStackView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
		NSLayoutConstraint.activate(contentView.constraints(equalTo: self))
		NSLayoutConstraint.activate([headerView.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 0.0),
		                             headerView.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 0.0),
		                             contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: headerView.trailingAnchor, multiplier: 0.0)])
		NSLayoutConstraint.activate([logItemsStackView.topAnchor.constraint(equalToSystemSpacingBelow: headerView.bottomAnchor, multiplier: 0.0),
		                             logItemsStackView.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 2.0),
		                             contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: logItemsStackView.trailingAnchor, multiplier: 2.0),
		                             contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: logItemsStackView.bottomAnchor, multiplier: 0.0)])
	}

	func setupGestures() {
		headerView.delegate = self
	}

	override func styleDidChange() {
		super.styleDidChange()
		let style = self.style()
		let cardBuilder = CardBuilder(cardView: self, contentView: contentView)
		cardBuilder.enableCardStyling(true, style: style)
		directionalLayoutMargins = style.dimension.directionalInsets1
	}

	@objc func didTapView() {
		delegate?.didSelectTaskView(self, eventIndexPath: .init(row: 0, section: 0))
	}

	@objc func itemTapped(_ sender: UIControl) {
		guard let index = logItemsStackView.arrangedSubviews.firstIndex(of: sender) else {
			fatalError("Target was not set up properly.")
		}
		delegate?.taskView(self, didSelectOutcomeValueAt: index, eventIndexPath: .init(row: 0, section: 0), sender: sender)
	}

	func clearItems(animated: Bool) {
		logItemsStackView.clear(animated: animated)
		headerView.shadowView.isHidden = true
	}

	func clearView(animated: Bool) {
		clearItems(animated: animated)
	}
}

extension TaskView: TaskViewUpdatable {
	var items: [TaskLogItem] {
		guard let buttons = logItemsStackView.arrangedSubviews as? [TaskLogItem] else {
			fatalError("Unsupported type.")
		}
		return buttons
	}

	func makeItem(value: String?, time: String?, context: String?, canEdit: Bool) -> TaskLogItem {
		let item = TaskLogItem()
		item.addTarget(self, action: #selector(itemTapped(_:)), for: .touchUpInside)
		item.valueLabel.text = value
		item.timeLabel.text = time
		item.contextLabel.text = context ?? " "
		item.imageView.image = canEdit ? UIImage(named: "icon-edit") : UIImage(named: "icon-lock-fill")
		item.accessibilityLabel = (value ?? "") + " " + (time ?? "") + " " + (context ?? "")
		item.accessibilityHint = loc("DOUBLE_TAP_TO_REMOVE_EVENT")
		return item
	}

	@discardableResult
	func updateItem(at index: Int, value: String?, time: String?, context: String?) -> TaskLogItem? {
		guard index < logItemsStackView.arrangedSubviews.count else { return nil }
		let button = items[index]
		button.accessibilityLabel = (value ?? "") + " " + (time ?? "") + " " + (context ?? "")
		button.valueLabel.text = value
		button.timeLabel.text = time
		button.contextLabel.text = context ?? " "
		return button
	}

	@discardableResult
	func insertItem(value: String?, time: String?, context: String?, at index: Int, animated: Bool, canEdit: Bool = true) -> TaskLogItem {
		let button = makeItem(value: value, time: time, context: context, canEdit: canEdit)
		logItemsStackView.insertArrangedSubview(button, at: index, animated: animated)
		headerView.shadowView.isHidden = false
		return button
	}

	@discardableResult
	func appendItem(value: String?, time: String?, context: String?, animated: Bool, canEdit: Bool) -> TaskLogItem {
		let button = makeItem(value: value, time: time, context: context, canEdit: canEdit)
		logItemsStackView.addArrangedSubview(button, animated: animated)
		headerView.shadowView.isHidden = false
		return button
	}

	@discardableResult
	func removeItem(at index: Int, animated: Bool) -> TaskLogItem? {
		guard index < logItemsStackView.arrangedSubviews.count else { return nil }
		let button = items[index]
		logItemsStackView.removeArrangedSubview(button, animated: animated)
		headerView.shadowView.isHidden = logItemsStackView.arrangedSubviews.isEmpty
		return button
	}
}

extension TaskView {
	/// Update the stack by updating each item, or adding a new one if necessary based on the number of `outcomeValues`.
	func updateItems(withOutcomeValues outcomeValues: [OCKOutcomeValue], animated: Bool) {
		if outcomeValues.isEmpty {
			clearItems(animated: animated)
		} else {
			for (index, outcomeValue) in outcomeValues.enumerated() {
				let date = outcomeValue.createdDate
				let dateString = ScheduleUtility.timeFormatter.string(from: date)
				let context = outcomeValue.insulinReasonTitle
				_ = index < items.count ?
					updateItem(at: index, value: outcomeValue.formattedValue, time: dateString, context: context) :
					appendItem(value: outcomeValue.formattedValue, time: dateString, context: context, animated: animated, canEdit: false)
			}
		}
		trimItems(given: outcomeValues, animated: animated)
	}

	func updateItems(withEvent event: OCKAnyEvent, animated: Bool) {
		if let outcome = event.outcome {
			let linkage = (event.task as? OCKHealthKitTask)?.healthKitLinkage
			updateItems(withOutcome: outcome, healthKitLinkage: linkage, animated: animated)
		} else {
			clearItems(animated: animated)
		}
	}

	func updateItems(withOutcome outcome: OCKAnyOutcome, healthKitLinkage linkage: OCKHealthKitLinkage?, animated: Bool) {
		let outcomeValues = outcome.values
		if outcomeValues.isEmpty {
			clearItems(animated: animated)
		} else {
			for (index, outcomeValue) in outcomeValues.enumerated() {
				let date = outcomeValue.createdDate
				let dateString = ScheduleUtility.timeFormatter.string(from: date)
				var context: String?
				if linkage?.quantityIdentifier == .insulinDelivery {
					context = outcomeValue.insulinReasonTitle
				} else if linkage?.quantityIdentifier == .bloodGlucose {
					context = outcomeValue.bloodGlucoseMealTimeTitle
				} else {
					context = outcomeValue.symptomTitle
				}
				_ = index < items.count ?
					updateItem(at: index, value: outcomeValue.formattedValue, time: dateString, context: context) :
					appendItem(value: outcomeValue.formattedValue, time: dateString, context: context, animated: animated, canEdit: true)
			}
		}
		trimItems(given: outcomeValues, animated: animated)
	}

	// Remove any items that aren't needed
	private func trimItems(given outcomeValues: [OCKOutcomeValue], animated: Bool) {
		guard items.count > outcomeValues.count else { return }
		let countToRemove = items.count - outcomeValues.count
		for _ in 0 ..< countToRemove {
			removeItem(at: items.count - 1, animated: animated)
		}
	}

	func updateWith(task: OCKAnyTask?, event: OCKAnyEvent?, animated: Bool) {
		headerView.updateWith(task: task, event: event, animated: animated)
		guard let event = event else {
			clearView(animated: animated)
			return
		}
		updateItems(withEvent: event, animated: animated)
	}
}

extension TaskView: TaskHeaderViewDelegate {
	func taskHeaderViewDidSelectButton(_ view: TaskHeaderView) {
		delegate?.didSelectTaskView(self, eventIndexPath: IndexPath(row: 0, section: 0))
	}
}
