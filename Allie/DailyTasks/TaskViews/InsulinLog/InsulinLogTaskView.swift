//
//  InsulinLogTaskView.swift
//  Allie
//
//  Created by Waqar Malik on 5/9/21.
//

import CareKitStore
import CareKitUI
import HealthKit
import UIKit

struct CardBuilder: OCKCardable {
	let cardView: UIView
	let contentView: UIView
}

class InsulinLogTaskView: OCKView, OCKTaskDisplayable {
	override init() {
		super.init(frame: .zero)
		setup()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private let contentView: OCKView = {
		let view = OCKView()
		view.clipsToBounds = true
		return view
	}()

	private lazy var headerButton = OCKAnimatedButton(contentView: headerView, highlightOptions: [.defaultDelayOnSelect, .defaultOverlay], handlesSelection: false)

	private let closeButton: UIButton = {
		let view = UIButton(type: .close)
		NSLayoutConstraint.activate([view.heightAnchor.constraint(equalToConstant: 32.0), view.widthAnchor.constraint(equalToConstant: 32.0)])
		return view
	}()

	private let headerStackView: OCKStackView = {
		let view = OCKStackView()
		view.axis = .vertical
		return view
	}()

	let contentStackView: OCKStackView = {
		let view = OCKStackView()
		view.axis = .vertical
		view.isLayoutMarginsRelativeArrangement = true
		return view
	}()

	let entryStackView: OCKStackView = {
		let view = OCKStackView()
		view.axis = .vertical
		view.isLayoutMarginsRelativeArrangement = true
		return view
	}()

	let instructionsLabel: OCKLabel = {
		let label = OCKLabel(textStyle: .footnote, weight: .medium)
		label.numberOfLines = 0
		label.lineBreakMode = .byWordWrapping
		return label
	}()

	let logButton: OCKLabeledButton = {
		let button = OCKLabeledButton()
		button.handlesSelection = false
		button.label.text = NSLocalizedString("LOG", comment: "Log")
		return button
	}()

	let shadowView: ShadowView = {
		let view = ShadowView(frame: .zero)
		view.heightAnchor.constraint(equalToConstant: 10.0).isActive = true
		return view
	}()

	let entryViews: LabelValueView = {
		let view = LabelValueView()
		view.axis = .horizontal
		return view
	}()

	let segmentedControl: UISegmentedControl = {
		let view = UISegmentedControl(items: [HKInsulinDeliveryReason.bolus.title, HKInsulinDeliveryReason.basal.title])
		let textAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.allieWhite]
		view.setTitleTextAttributes(textAttributes, for: .selected)
		view.selectedSegmentTintColor = .allieGray
		view.selectedSegmentIndex = 0
		return view
	}()

	let doneButton: OCKLabeledButton = {
		let button = OCKLabeledButton()
		button.handlesSelection = false
		button.label.text = NSLocalizedString("DONE", comment: "Done")
		return button
	}()

	weak var delegate: OCKTaskViewDelegate?

	public let headerView = OCKHeaderView {
		$0.showsSeparator = true
		$0.showsDetailDisclosure = false
	}

	let logItemsStackView: OCKStackView = {
		var stackView = OCKStackView()
		stackView.axis = .vertical
		return stackView
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
		contentView.addSubview(headerStackView)
		[headerButton, entryViews, segmentedControl, contentStackView].forEach { headerStackView.addArrangedSubview($0) }
		[shadowView, entryViews, segmentedControl, doneButton].forEach { entryStackView.addArrangedSubview($0) }
		[instructionsLabel, logButton, logItemsStackView].forEach { contentStackView.addArrangedSubview($0) }
		addSubview(closeButton)
	}

	func constrainSubviews() {
		[contentView, headerStackView, headerView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
		[entryStackView, shadowView, entryViews, segmentedControl, doneButton].forEach { view in
			view.translatesAutoresizingMaskIntoConstraints = false
		}
		NSLayoutConstraint.activate(
			contentView.constraints(equalTo: self) +
				headerStackView.constraints(equalTo: contentView) +
				headerView.constraints(equalTo: headerButton.layoutMarginsGuide, directions: [.horizontal, .top]) +
				headerView.constraints(equalTo: headerButton, directions: [.bottom]))
		entryViews.heightAnchor.constraint(equalToConstant: 45.0).isActive = true
		segmentedControl.heightAnchor.constraint(equalToConstant: 45.0).isActive = true
		closeButton.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([closeButton.centerYAnchor.constraint(equalTo: headerButton.centerYAnchor, constant: 0.0),
		                             trailingAnchor.constraint(equalToSystemSpacingAfter: closeButton.trailingAnchor, multiplier: 2.0)])
		closeButton.isHidden = true
	}

	private func setupGestures() {
		headerButton.addTarget(self, action: #selector(didTapView), for: .touchUpInside)
		doneButton.addTarget(self, action: #selector(didTapDoneButton(_:)), for: .touchUpInside)
		logButton.addTarget(self, action: #selector(didTapLogButton(_:)), for: .touchUpInside)
		closeButton.addTarget(self, action: #selector(closeEntryView(_:)), for: .touchUpInside)
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

	@objc func didTapLogButton(_ sender: UIControl) {
		guard let index = contentStackView.arrangedSubviews.firstIndex(of: logButton) else {
			return
		}
		contentStackView.removeArrangedSubview(logButton, animated: true)
		contentStackView.insertArrangedSubview(entryStackView, at: index, animated: true)
		closeButton.isHidden = false
	}

	@objc func didTapDoneButton(_ sender: UIControl) {
		delegate?.taskView(self, didCreateOutcomeValueAt: 0, eventIndexPath: .init(row: 0, section: 0), sender: sender)
		closeEntryView(sender)
	}

	@objc func closeEntryView(_ sender: UIControl) {
		guard let index = contentStackView.arrangedSubviews.firstIndex(of: entryStackView) else {
			return
		}
		contentStackView.removeArrangedSubview(entryStackView, animated: true)
		contentStackView.insertArrangedSubview(logButton, at: index, animated: true)
		entryViews.prepareForReuse()
		closeButton.isHidden = true
	}

	var reason: HKInsulinDeliveryReason {
		segmentedControl.selectedSegmentIndex == 0 ? .bolus : .basal
	}

	var items: [InsulinLogItemButton] {
		guard let buttons = logItemsStackView.arrangedSubviews as? [InsulinLogItemButton] else {
			fatalError("Unsupported type.")
		}
		return buttons
	}

	private func makeItem(withTitle title: String?, detail: String?) -> InsulinLogItemButton {
		let button = InsulinLogItemButton()
		// button.addTarget(self, action: #selector(itemTapped(_:)), for: .touchUpInside)
		button.titleLabel.text = title
		button.detailLabel.text = detail
		button.accessibilityLabel = (detail ?? "") + " " + (title ?? "")
//		button.accessibilityHint = loc("DOUBLE_TAP_TO_REMOVE_EVENT")
		return button
	}

	private func makeTitle(units: String) -> String {
		let selectedIndex = segmentedControl.selectedSegmentIndex
		var string = segmentedControl.titleForSegment(at: selectedIndex) ?? ""
		string += " " + units + " " + NSLocalizedString("UNITS", comment: "Units")
		return string
	}

	override func styleDidChange() {
		super.styleDidChange()
		let style = self.style()
		let cardBuilder = CardBuilder(cardView: self, contentView: contentView)
		cardBuilder.enableCardStyling(true, style: style)
		contentStackView.spacing = style.dimension.directionalInsets1.top
		entryStackView.spacing = style.dimension.directionalInsets1.top
		directionalLayoutMargins = style.dimension.directionalInsets1
		contentStackView.directionalLayoutMargins = style.dimension.directionalInsets1
	}

	@discardableResult
	func updateItem(at index: Int, withTitle title: String?, detail: String?) -> InsulinLogItemButton? {
		guard index < logItemsStackView.arrangedSubviews.count else { return nil }
		let button = items[index]
		button.accessibilityLabel = title
		button.titleLabel.text = title
		button.detailLabel.text = detail
		return button
	}

	@discardableResult
	func insertItem(withTitle title: String?, detail: String?, at index: Int, animated: Bool) -> InsulinLogItemButton {
		let button = makeItem(withTitle: title, detail: detail)
		logItemsStackView.insertArrangedSubview(button, at: index, animated: animated)
		return button
	}

	@discardableResult
	func appendItem(withTitle title: String?, detail: String?, animated: Bool) -> InsulinLogItemButton {
		let button = makeItem(withTitle: title, detail: detail)
		logItemsStackView.addArrangedSubview(button, animated: animated)
		return button
	}

	@discardableResult
	func removeItem(at index: Int, animated: Bool) -> InsulinLogItemButton? {
		guard index < logItemsStackView.arrangedSubviews.count else { return nil }
		let button = items[index]
		logItemsStackView.removeArrangedSubview(button, animated: animated)
		return button
	}

	func clearItems(animated: Bool) {
		logItemsStackView.clear(animated: animated)
	}
}

extension InsulinLogTaskView {
	static let timeFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.timeStyle = .short
		return formatter
	}()

	/// Update the stack by updating each item, or adding a new one if necessary based on the number of `outcomeValues`.
	func updateItems(withOutcomeValues outcomeValues: [OCKOutcomeValue], animated: Bool) {
		if outcomeValues.isEmpty {
			clearItems(animated: animated)
		} else {
			for (index, outcomeValue) in outcomeValues.enumerated() {
				let date = outcomeValue.createdDate
				let dateString = InsulinLogTaskView.timeFormatter.string(from: date)
				let kind = HKInsulinDeliveryReason(kind: outcomeValue.kind ?? "")
				let value = outcomeValue.doubleValue ?? 0.0
				let title = "\(kind?.title ?? "") \(value) " + NSLocalizedString("UNITS", comment: "Units")
				_ = index < items.count ?
					updateItem(at: index, withTitle: dateString, detail: title) :
					appendItem(withTitle: dateString, detail: title, animated: animated)
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
		instructionsLabel.text = event.task.instructions
		updateItems(withOutcomeValues: event.outcome?.values ?? [], animated: animated)
	}

	func clearView(animated: Bool) {
		instructionsLabel.text = nil
		clearItems(animated: animated)
	}
}
