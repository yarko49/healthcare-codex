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

	let gradientView: GradientView = {
		let view = GradientView(frame: .zero)
		view.colors = [UIColor(white: 0.0, alpha: 0.1), UIColor(white: 0.0, alpha: 0.0)]
		view.startPoint = CGPoint(x: 0.0, y: 0.0)
		view.endPoint = CGPoint(x: 0.0, y: 1.0)
		view.heightAnchor.constraint(equalToConstant: 10.0).isActive = true
		return view
	}()

	let entryViews: LabelValuesView = {
		let view = LabelValuesView()
		view.axis = .horizontal
		return view
	}()

	let segmentedControl: UISegmentedControl = {
		let view = UISegmentedControl(items: [HKInsulinDeliveryReason.bolus.title, HKInsulinDeliveryReason.basal.title])
		let textAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.allieWhite]
		view.setTitleTextAttributes(textAttributes, for: .selected)
		view.selectedSegmentTintColor = .allieButtons
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
		[gradientView, entryViews, segmentedControl, doneButton].forEach { entryStackView.addArrangedSubview($0) }
		[instructionsLabel, logButton, logItemsStackView].forEach { contentStackView.addArrangedSubview($0) }
	}

	func constrainSubviews() {
		[contentView, headerStackView, headerView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
		[entryStackView, gradientView, entryViews, segmentedControl, doneButton].forEach { view in
			view.translatesAutoresizingMaskIntoConstraints = false
		}
		NSLayoutConstraint.activate(
			contentView.constraints(equalTo: self) +
				headerStackView.constraints(equalTo: contentView) +
				headerView.constraints(equalTo: headerButton.layoutMarginsGuide, directions: [.horizontal, .top]) +
				headerView.constraints(equalTo: headerButton, directions: [.bottom]))
		entryViews.heightAnchor.constraint(equalToConstant: 45.0).isActive = true
		segmentedControl.heightAnchor.constraint(equalToConstant: 45.0).isActive = true
	}

	private func setupGestures() {
		headerButton.addTarget(self, action: #selector(didTapView), for: .touchUpInside)
		doneButton.addTarget(self, action: #selector(didTapDoneButton(_:)), for: .touchUpInside)
		logButton.addTarget(self, action: #selector(didTapLogButton(_:)), for: .touchUpInside)
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
	}

	@objc func didTapDoneButton(_ sender: UIControl) {
		guard let units = entryViews.units, !units.isEmpty, let value = Double(units) else {
			return
		}
		let sample = HKDiscreteQuantitySample(insulinUnits: value, startDate: entryViews.entryDate, reason: reason)
		HKHealthStore().save(sample) { [weak self] _, error in
			if let error = error {
				ALog.error("Unable to save insulin values", error: error)
			} else {
				DispatchQueue.main.async {
					guard let strongSelf = self else {
						return
					}
					let detail = strongSelf.makeTitle(units: units)
					let itemCount = strongSelf.items.count
					let title = InsulinLogTaskView.timeFormatter.string(from: strongSelf.entryViews.entryDate)
					strongSelf.appendItem(withTitle: title, detail: detail, animated: true)
					strongSelf.delegate?.taskView(strongSelf, didCreateOutcomeValueAt: itemCount, eventIndexPath: .init(row: 0, section: 0), sender: sender)
					guard let index = strongSelf.contentStackView.arrangedSubviews.firstIndex(of: strongSelf.entryStackView) else {
						return
					}
					strongSelf.contentStackView.removeArrangedSubview(strongSelf.entryStackView, animated: true)
					strongSelf.contentStackView.insertArrangedSubview(strongSelf.logButton, at: index, animated: true)
				}
			}
		}
	}

	var reason: HKInsulinDeliveryReason {
		segmentedControl.selectedSegmentIndex == 0 ? .bolus : .basal
	}

	var items: [InsulinLogItemButton] {
		guard let buttons = logItemsStackView.arrangedSubviews as? [InsulinLogItemButton] else { fatalError("Unsupported type.") }
		return buttons
	}

	private func makeItem(withTitle title: String?, detail: String?) -> InsulinLogItemButton {
		let button = InsulinLogItemButton()
		button.addTarget(self, action: #selector(itemTapped(_:)), for: .touchUpInside)
		button.titleLabel.text = title
		button.detailLabel.text = detail
		button.accessibilityLabel = (detail ?? "") + " " + (title ?? "")
		button.accessibilityHint = loc("DOUBLE_TAP_TO_REMOVE_EVENT")
		return button
	}

	private func makeTitle(units: String) -> String {
		let selectedIndex = segmentedControl.selectedSegmentIndex
		var string = segmentedControl.titleForSegment(at: selectedIndex) ?? ""
		string += " " + units + " Units"
		return string
	}

	private func makeOutcome() -> OCKOutcome {
		let value = Double(entryViews.units ?? "") ?? 0
		let time = entryViews.entryDate
		var outcomeValue = OCKOutcomeValue(value, units: "IU")
		outcomeValue.kind = segmentedControl.selectedSegmentIndex == 0 ? HKInsulinDeliveryReason.bolus.kind : HKInsulinDeliveryReason.basal.kind
		outcomeValue.createdDate = time
		var outcome = OCKOutcome(taskUUID: UUID(), taskOccurrenceIndex: 0, values: [outcomeValue])
		outcome.createdDate = time
		return outcome
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
				let dateString = InsulinLogTaskView.timeFormatter.string(from: date).description

				_ = index < items.count ?
					updateItem(at: index, withTitle: outcomeValue.stringValue, detail: dateString) :
					appendItem(withTitle: outcomeValue.stringValue, detail: dateString, animated: animated)
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

		// updateItems(withOutcomeValues: event.outcome?.values ?? [], animated: animated)
	}

	func clearView(animated: Bool) {
		instructionsLabel.text = nil
		clearItems(animated: animated)
	}
}
