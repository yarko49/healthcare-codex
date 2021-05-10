//
//  InsulinLogTaskView.swift
//  Allie
//
//  Created by Waqar Malik on 5/9/21.
//

import CareKitUI
import UIKit

private class LogButton: OCKLabeledButton {
	override init() {
		super.init()
		handlesSelection = false
		label.text = loc("Log")
	}
}

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

	let notesTextField: UITextField = {
		let textField = UITextField(frame: .zero)
		textField.placeholder = "Some note could be added here"
		textField.font = UIFont.preferredFont(forTextStyle: .footnote)
		return textField
	}()

	let entryViews: LabelValuesView = {
		let view = LabelValuesView()
		view.axis = .horizontal
		return view
	}()

	let segmentedControl: UISegmentedControl = {
		let title1 = NSLocalizedString("FAST_ACTING", comment: "Fast Acting")
		let title2 = NSLocalizedString("LONG_ACTING", comment: "Long Acting")
		let view = UISegmentedControl(items: [title1, title2])
		return view
	}()

	let logButton: OCKLabeledButton = {
		let button = OCKLabeledButton()
		button.handlesSelection = false
		button.label.text = loc("Log")
		return button
	}()

	weak var delegate: OCKTaskViewDelegate?

	public let headerView = OCKHeaderView {
		$0.showsSeparator = true
		$0.showsDetailDisclosure = false
	}

	let logItemsStackView: OCKStackView = {
		var stackView = OCKStackView(style: .separated)
		stackView.showsOuterSeparators = false
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
		[notesTextField, entryViews, segmentedControl, logButton, logItemsStackView].forEach { contentStackView.addArrangedSubview($0) }
		logItemsStackView.isHidden = true
	}

	func constrainSubviews() {
		[contentView, headerStackView, headerView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
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
	}

	@objc
	private func didTapView() {
		delegate?.didSelectTaskView(self, eventIndexPath: .init(row: 0, section: 0))
	}

	@objc
	private func itemTapped(_ sender: UIControl) {
		guard let index = logItemsStackView.arrangedSubviews.firstIndex(of: sender) else {
			fatalError("Target was not set up properly.")
		}
		delegate?.taskView(self, didSelectOutcomeValueAt: index, eventIndexPath: .init(row: 0, section: 0), sender: sender)
	}

	var items: [OCKLogItemButton] {
		guard let buttons = logItemsStackView.arrangedSubviews as? [OCKLogItemButton] else { fatalError("Unsupported type.") }
		return buttons
	}

	private func makeItem(withTitle title: String?, detail: String?) -> OCKLogItemButton {
		let button = OCKLogItemButton()
		button.addTarget(self, action: #selector(itemTapped(_:)), for: .touchUpInside)
		button.titleLabel.text = title
		button.detailLabel.text = detail
		button.accessibilityLabel = (detail ?? "") + " " + (title ?? "")
		button.accessibilityHint = loc("DOUBLE_TAP_TO_REMOVE_EVENT")
		return button
	}

	override func styleDidChange() {
		super.styleDidChange()
		let style = self.style()
		let cardBuilder = CardBuilder(cardView: self, contentView: contentView)
		cardBuilder.enableCardStyling(true, style: style)
		contentStackView.spacing = style.dimension.directionalInsets1.top
		directionalLayoutMargins = style.dimension.directionalInsets1
		contentStackView.directionalLayoutMargins = style.dimension.directionalInsets1
	}

	@discardableResult
	func updateItem(at index: Int, withTitle title: String?, detail: String?) -> OCKLogItemButton? {
		guard index < logItemsStackView.arrangedSubviews.count else { return nil }
		let button = items[index]
		button.accessibilityLabel = title
		button.titleLabel.text = title
		button.detailLabel.text = detail
		return button
	}

	@discardableResult
	func insertItem(withTitle title: String?, detail: String?, at index: Int, animated: Bool) -> OCKLogItemButton {
		let button = makeItem(withTitle: title, detail: detail)
		logItemsStackView.insertArrangedSubview(button, at: index, animated: animated)
		return button
	}

	@discardableResult
	func appendItem(withTitle title: String?, detail: String?, animated: Bool) -> OCKLogItemButton {
		let button = makeItem(withTitle: title, detail: detail)
		logItemsStackView.addArrangedSubview(button, animated: animated)
		return button
	}

	@discardableResult
	func removeItem(at index: Int, animated: Bool) -> OCKLogItemButton? {
		guard index < logItemsStackView.arrangedSubviews.count else { return nil }
		let button = items[index]
		logItemsStackView.removeArrangedSubview(button, animated: animated)
		return button
	}

	func clearItems(animated: Bool) {
		logItemsStackView.clear(animated: animated)
	}
}
