//
//  EntryTaskSectionFooterView.swift
//  Allie
//
//  Created by Waqar Malik on 7/9/21.
//

import UIKit

protocol EntryTaskSectionFooterViewDelegate: AnyObject {
	func entryTaskSectionFooterViewDidSelectButton(_ view: EntryTaskSectionFooterView)
}

class EntryTaskSectionFooterView: UICollectionReusableView {
	class var height: CGFloat {
		45.0 + 22.0
	}

	weak var delegate: EntryTaskSectionFooterViewDelegate?

	let button: UIButton = {
		let button = UIButton(type: .system)
		button.layer.cornerRadius = 8.0
		button.layer.cornerCurve = .continuous
		button.backgroundColor = .allieGray
		button.setTitleColor(.allieWhite, for: .normal)
		button.setTitle(NSLocalizedString("SAVE", comment: "Save"), for: .normal)
		return button
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func commonInit() {
		button.translatesAutoresizingMaskIntoConstraints = false
		addSubview(button)
		NSLayoutConstraint.activate([button.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 0.0),
		                             button.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 22.0 / 8.0),
		                             trailingAnchor.constraint(equalToSystemSpacingAfter: button.trailingAnchor, multiplier: 22.0 / 8.0),
		                             bottomAnchor.constraint(equalToSystemSpacingBelow: button.bottomAnchor, multiplier: 22.0 / 8.0)])
		button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
	}

	@objc func buttonAction(_ sender: Any?) {
		delegate?.entryTaskSectionFooterViewDidSelectButton(self)
	}
}
