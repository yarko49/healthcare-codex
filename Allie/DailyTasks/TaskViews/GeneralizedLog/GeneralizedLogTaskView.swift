//
//  GeneralizedLogTaskView.swift
//  Allie
//
//  Created by Waqar Malik on 7/10/21.
//

import CareKitStore
import CareKitUI
import HealthKit
import UIKit

struct CardBuilder: OCKCardable {
	let cardView: UIView
	let contentView: UIView
}

class GeneralizedLogTaskView: OCKView, OCKTaskDisplayable {
	override init() {
		super.init(frame: .zero)
		setup()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	weak var delegate: OCKTaskViewDelegate?

	var items: [GeneralizedLogItem] {
		guard let buttons = logItemsStackView.arrangedSubviews as? [GeneralizedLogItem] else {
			fatalError("Unsupported type.")
		}
		return buttons
	}

	private lazy var headerButton = {
		OCKAnimatedButton(contentView: headerView, highlightOptions: [.defaultDelayOnSelect, .defaultOverlay], handlesSelection: false)
	}()

	private let contentView: OCKView = {
		let view = OCKView()
		view.clipsToBounds = true
		return view
	}()

	let headerView: EntryTaskSectionHeaderView = {
		let view = EntryTaskSectionHeaderView(frame: .zero)
		view.button.setImage(UIImage(systemName: "plus"), for: .normal)
		view.button.backgroundColor = .allieGray
		view.textLabel.font = UIFont.systemFont(ofSize: 16.0, weight: .bold)
		view.textLabel.textColor = .allieGray
		view.detailTextLabel.text = "Instructions"
		view.imageView.image = UIImage(named: "icon-insulin")
		view.heightAnchor.constraint(equalToConstant: EntryTaskSectionHeaderView.height).isActive = true
		return view
	}()

	let logItemsStackView: OCKStackView = {
		var view = OCKStackView()
		view.axis = .vertical
		return view
	}()

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

	private func setupGestures() {
		headerView.delegate = self
	}

	@objc func didTapView() {
		delegate?.didSelectTaskView(self, eventIndexPath: .init(row: 0, section: 0))
	}

	override func styleDidChange() {
		super.styleDidChange()
		let style = self.style()
		let cardBuilder = CardBuilder(cardView: self, contentView: contentView)
		cardBuilder.enableCardStyling(true, style: style)
		directionalLayoutMargins = style.dimension.directionalInsets1
	}

	private func makeItem(value: String?, time: String?, context: String?, canDelete: Bool) -> GeneralizedLogItem {
		let item = GeneralizedLogItem()
		item.addTarget(self, action: #selector(itemTapped(_:)), for: .touchUpInside)
		item.valueLabel.text = value
		item.timeLabel.text = time
		item.contextLabel.text = context ?? " "
		item.imageView.image = canDelete ? UIImage(systemName: "trash") : UIImage(named: "icon-lock-fill")
		item.accessibilityLabel = (value ?? "") + " " + (time ?? "") + " " + (context ?? "")
		item.accessibilityHint = loc("DOUBLE_TAP_TO_REMOVE_EVENT")
		return item
	}

	@objc func itemTapped(_ sender: UIControl) {
		guard let index = logItemsStackView.arrangedSubviews.firstIndex(of: sender) else {
			fatalError("Target was not set up properly.")
		}
		delegate?.taskView(self, didSelectOutcomeValueAt: index, eventIndexPath: .init(row: 0, section: 0), sender: sender)
	}

	@discardableResult
	func updateItem(at index: Int, value: String?, time: String?, context: String?) -> GeneralizedLogItem? {
		guard index < logItemsStackView.arrangedSubviews.count else { return nil }
		let button = items[index]
		button.accessibilityLabel = (value ?? "") + " " + (time ?? "") + " " + (context ?? "")
		button.valueLabel.text = value
		button.timeLabel.text = time
		button.contextLabel.text = context ?? " "
		return button
	}

	@discardableResult
	func insertItem(value: String?, time: String?, context: String?, at index: Int, animated: Bool, canDelete: Bool) -> GeneralizedLogItem {
		let button = makeItem(value: value, time: time, context: context, canDelete: canDelete)
		logItemsStackView.insertArrangedSubview(button, at: index, animated: animated)
		headerView.shadowView.isHidden = false
		return button
	}

	@discardableResult
	func appendItem(value: String?, time: String?, context: String?, animated: Bool, canDelete: Bool) -> GeneralizedLogItem {
		let button = makeItem(value: value, time: time, context: context, canDelete: canDelete)
		logItemsStackView.addArrangedSubview(button, animated: animated)
		headerView.shadowView.isHidden = false
		return button
	}

	@discardableResult
	func removeItem(at index: Int, animated: Bool) -> GeneralizedLogItem? {
		guard index < logItemsStackView.arrangedSubviews.count else { return nil }
		let button = items[index]
		logItemsStackView.removeArrangedSubview(button, animated: animated)
		headerView.shadowView.isHidden = logItemsStackView.arrangedSubviews.isEmpty
		return button
	}

	func clearItems(animated: Bool) {
		logItemsStackView.clear(animated: animated)
		headerView.shadowView.isHidden = true
	}
}

extension GeneralizedLogTaskView {
	/// Update the stack by updating each item, or adding a new one if necessary based on the number of `outcomeValues`.
	func updateItems(withOutcomeValues outcomeValues: [OCKOutcomeValue], animated: Bool) {
		if outcomeValues.isEmpty {
			clearItems(animated: animated)
		} else {
			for (index, outcomeValue) in outcomeValues.enumerated() {
				let date = outcomeValue.createdDate
				let dateString = ScheduleUtility.timeFormatter.string(from: date)
				let context = outcomeValue.insulinReason
				_ = index < items.count ?
					updateItem(at: index, value: outcomeValue.formattedValue, time: dateString, context: context) :
					appendItem(value: outcomeValue.formattedValue, time: dateString, context: context, animated: animated, canDelete: false)
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
			let canDelete = (outcome as? OCKHealthKitOutcome)?.isOwnedByApp ?? false
			for (index, outcomeValue) in outcomeValues.enumerated() {
				let date = outcomeValue.createdDate
				let dateString = ScheduleUtility.timeFormatter.string(from: date)
				var context: String?
				if linkage?.quantityIdentifier == .insulinDelivery {
					context = outcomeValue.insulinReason
				} else if linkage?.quantityIdentifier == .bloodGlucose {
					context = outcomeValue.bloodGlucoseMealTime
				}

				_ = index < items.count ?
					updateItem(at: index, value: outcomeValue.formattedValue, time: dateString, context: context) :
					appendItem(value: outcomeValue.formattedValue, time: dateString, context: context, animated: animated, canDelete: canDelete)
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

	func updateWith(event: OCKAnyEvent?, animated: Bool) {
		headerView.updateWith(event: event, animated: animated)
		guard let event = event else {
			clearView(animated: animated)
			return
		}
		updateItems(withEvent: event, animated: animated)
	}

	func clearView(animated: Bool) {
		clearItems(animated: animated)
	}
}

extension GeneralizedLogTaskView: EntryTaskSectionHeaderViewDelegate {
	func entryTaskSectionHeaderViewDidSelectButton(_ view: EntryTaskSectionHeaderView) {
		delegate?.didSelectTaskView(self, eventIndexPath: IndexPath(row: 0, section: 0))
	}
}

extension EntryTaskSectionHeaderView {
	func updateWith(event: OCKAnyEvent?, animated: Bool) {
		guard let event = event else {
			clearView(animated: animated)
			return
		}

		textLabel.text = event.task.title
		detailTextLabel.text = ScheduleUtility.scheduleLabel(for: event)
		let quantityIdentifier = (event.task as? OCKHealthKitTask)?.healthKitLinkage.quantityIdentifier
		if let dataType = quantityIdentifier?.dataType {
			imageView.image = dataType.image
		}
		updateAccessibilityLabel()
	}

	func updateWith(events: [OCKAnyEvent]?, animated: Bool) {
		guard let events = events, !events.isEmpty else {
			clearView(animated: animated)
			return
		}

		let task = events.first!.task
		textLabel.text = task.title
		detailTextLabel.text = ScheduleUtility.scheduleLabel(for: events)
		if let dataType = (task as? OCKHealthKitTask)?.healthKitLinkage.quantityIdentifier.dataType {
			imageView.image = dataType.image
		}
		updateAccessibilityLabel()
	}

	func clearView(animated: Bool) {
		[textLabel, detailTextLabel].forEach { $0.text = nil }
		imageView.image = UIImage(named: "icon-empty")
		accessibilityLabel = nil
	}

	func updateAccessibilityLabel() {
		accessibilityLabel = "\(textLabel.text ?? ""), \(detailTextLabel.text ?? "")"
	}
}
