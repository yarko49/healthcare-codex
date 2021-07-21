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
			if identifier == SegmentedEntryView.reuseIdentifier {
				cell = SegmentedEntryView(frame: .zero)
				cell?.heightAnchor.constraint(equalToConstant: SegmentedEntryView.height).isActive = true
				cell?.translatesAutoresizingMaskIntoConstraints = false
				entryViews[SegmentedEntryView.reuseIdentifier] = cell
			} else if identifier == TimeValueEntryView.reuseIdentifier {
				cell = TimeValueEntryView(frame: .zero)
				cell?.heightAnchor.constraint(equalToConstant: TimeValueEntryView.height).isActive = true
				cell?.translatesAutoresizingMaskIntoConstraints = false
				entryViews[TimeValueEntryView.reuseIdentifier] = cell
			} else if identifier == MultiValueEntryView.reuseIdentifier {
				cell = MultiValueEntryView(frame: .zero)
				cell?.heightAnchor.constraint(equalToConstant: MultiValueEntryView.height).isActive = true
				cell?.translatesAutoresizingMaskIntoConstraints = false
				entryViews[MultiValueEntryView.reuseIdentifier] = cell
			}
		}
		contentStackView.insertArrangedSubview(cell!, at: index)
		return cell!
	}
}
