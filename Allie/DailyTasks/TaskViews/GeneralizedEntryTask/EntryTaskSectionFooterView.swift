//
//  EntryTaskSectionFooterView.swift
//  Allie
//
//  Created by Waqar Malik on 7/9/21.
//

import Combine
import UIKit

protocol EntryTaskSectionFooterViewDelegate: AnyObject {
	func entryTaskSectionFooterViewDidSelectSave(_ view: EntryTaskSectionFooterView)
	func entryTaskSectionFooterViewDidSelectDelete(_ view: EntryTaskSectionFooterView)
}

class EntryTaskSectionFooterView: UICollectionReusableView {
	class var height: CGFloat {
		45.0 + 22.0
	}

	weak var delegate: EntryTaskSectionFooterViewDelegate?

	let stackView: UIStackView = {
		let view = UIStackView(frame: .zero)
		view.axis = .horizontal
		view.spacing = 9.0
		view.distribution = .fillEqually
		view.alignment = .fill
		return view
	}()

	let deleteButton: UIButton = {
		let button = UIButton(type: .system)
		button.layer.cornerRadius = 8.0
		button.layer.cornerCurve = .continuous
		button.backgroundColor = .allieWhite
		button.setTitleColor(.allieGray, for: .normal)
		button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .regular)
		button.layer.borderColor = UIColor.allieGray.cgColor
		button.layer.borderWidth = 1.0
		button.setTitle(NSLocalizedString("DELETE", comment: "Delete"), for: .normal)
		return button
	}()

	let saveButton: UIButton = {
		let button = UIButton(type: .system)
		button.layer.cornerRadius = 8.0
		button.layer.cornerCurve = .continuous
		button.backgroundColor = .allieGray
		button.setTitleColor(.allieWhite, for: .normal)
		button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .regular)
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
		[stackView, deleteButton, saveButton].forEach { view in
			view.translatesAutoresizingMaskIntoConstraints = false
		}
		addSubview(stackView)
		NSLayoutConstraint.activate([stackView.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 0.0),
		                             stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 22.0 / 8.0),
		                             trailingAnchor.constraint(equalToSystemSpacingAfter: stackView.trailingAnchor, multiplier: 22.0 / 8.0),
		                             bottomAnchor.constraint(equalToSystemSpacingBelow: stackView.bottomAnchor, multiplier: 22.0 / 8.0)])
		stackView.addArrangedSubview(deleteButton)
		stackView.addArrangedSubview(saveButton)
		deleteButton.addTarget(self, action: #selector(deleteItem(_:)), for: .touchUpInside)
		saveButton.addTarget(self, action: #selector(saveItem(_:)), for: .touchUpInside)
	}

	@objc func saveItem(_ sender: Any?) {
		delegate?.entryTaskSectionFooterViewDidSelectSave(self)
	}

	@objc func deleteItem(_ sender: Any?) {
		delegate?.entryTaskSectionFooterViewDidSelectDelete(self)
	}
}
