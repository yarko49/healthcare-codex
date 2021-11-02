//
//  GeneralizedLogTaskDetailView.swift
//  Allie
//
//  Created by Waqar Malik on 7/10/21.
//

import CareKitUI
import UIKit

class GeneralizedLogTaskDetailView: OCKStackView {
	override init(style: OCKStackView.Style = .plain) {
		super.init(style: style)
		commonInit()
	}

	@available(*, unavailable)
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	let contentStackView: OCKStackView = {
		let view = OCKStackView()
		view.axis = .vertical
		view.spacing = 22.0
		view.distribution = .fill
		view.alignment = .fill
		return view
	}()

	private var entryViews: [String: UIView] = [:]
	private func commonInit() {
		axis = .vertical
		spacing = 22.0
		distribution = .fill
		alignment = .fill
		backgroundColor = .allieWhite
		layer.cornerRadius = 11.0
		layer.cornerCurve = .continuous

		contentStackView.translatesAutoresizingMaskIntoConstraints = false
		addArrangedSubview(contentStackView)
	}

	func entryView(forIdentifier identifier: String) -> UIView? {
		entryViews[identifier]
	}

	func dequeueCell(identifier: String, at index: Int) -> UIView {
		var cell = entryViews[identifier]
		if let cell = cell {
			contentStackView.removeArrangedSubview(cell)
		}
		if cell == nil {
			if identifier == EntrySegmentedView.reuseIdentifier {
				cell = EntrySegmentedView(frame: .zero)
				cell?.heightAnchor.constraint(equalToConstant: EntrySegmentedView.height).isActive = true
				cell?.translatesAutoresizingMaskIntoConstraints = false
				entryViews[EntrySegmentedView.reuseIdentifier] = cell
			} else if identifier == EntryTimePickerView.reuseIdentifier {
				cell = EntryTimePickerView(frame: .zero)
				cell?.heightAnchor.constraint(equalToConstant: EntryTimePickerView.height).isActive = true
				cell?.translatesAutoresizingMaskIntoConstraints = false
				entryViews[EntryTimePickerView.reuseIdentifier] = cell
			} else if identifier == EntryMultiValueEntryView.reuseIdentifier {
				cell = EntryMultiValueEntryView(frame: .zero)
				cell?.heightAnchor.constraint(equalToConstant: EntryMultiValueEntryView.height).isActive = true
				cell?.translatesAutoresizingMaskIntoConstraints = false
				entryViews[EntryMultiValueEntryView.reuseIdentifier] = cell
			} else if identifier == EntryListPickerView.reuseIdentifier {
				cell = EntryListPickerView(frame: .zero)
				cell?.heightAnchor.constraint(equalToConstant: EntryListPickerView.height).isActive = true
				cell?.translatesAutoresizingMaskIntoConstraints = false
				entryViews[EntryListPickerView.reuseIdentifier] = cell
			}
		}
		contentStackView.insertArrangedSubview(cell!, at: index)
		return cell!
	}
}
