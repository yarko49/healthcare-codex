//
//  SegmentedEntryView.swift
//  Allie
//
//  Created by Waqar Malik on 7/7/21.
//

import UIKit

protocol SegmentedEntryViewDelegate: AnyObject {
	func segmentedEntryView(_ view: SegmentedEntryView, didSelectItem index: Int)
}

class SegmentedEntryView: UIView {
	class var height: CGFloat {
		45.0
	}

	class var reuseIdentifier: String {
		String(describing: self)
	}

	weak var delegate: SegmentedEntryViewDelegate?

	let segementedControl: UISegmentedControl = {
		let view = UISegmentedControl(frame: .zero)
		let textAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.allieWhite]
		view.setTitleTextAttributes(textAttributes, for: .selected)
		view.selectedSegmentTintColor = .allieGray
		return view
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}

	func configure(titles: [String]) {
		segementedControl.removeAllSegments()
		for (index, title) in titles.enumerated() {
			segementedControl.insertSegment(withTitle: title, at: index, animated: false)
		}
		segementedControl.selectedSegmentIndex = 0
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	@objc func valueChanged(_ control: UISegmentedControl) {
		delegate?.segmentedEntryView(self, didSelectItem: control.selectedSegmentIndex)
	}

	private func commonInit() {
		segementedControl.translatesAutoresizingMaskIntoConstraints = false
		addSubview(segementedControl)
		NSLayoutConstraint.activate([segementedControl.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 22.0 / 8.0),
		                             segementedControl.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 0.0),
		                             trailingAnchor.constraint(equalToSystemSpacingAfter: segementedControl.trailingAnchor, multiplier: 22.0 / 8.0),
		                             bottomAnchor.constraint(equalToSystemSpacingBelow: segementedControl.bottomAnchor, multiplier: 0.0)])
		segementedControl.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
	}
}
