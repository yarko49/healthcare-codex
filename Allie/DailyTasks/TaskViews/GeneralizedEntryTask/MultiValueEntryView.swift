//
//  MultiValueEntryView.swift
//  Allie
//
//  Created by Waqar Malik on 7/7/21.
//

import CareKitUI
import UIKit

class MultiValueEntryView: UIView {
	class var height: CGFloat {
		48.0
	}

	class var reuseIdentifier: String {
		String(describing: self)
	}

	let leadingEntryView: LabeledTextEntryView = {
		let view = LabeledTextEntryView(frame: .zero)
		view.textField.placeholder = "120"
		view.textLabel.text = "mmHg"
		return view
	}()

	let trailingEntryView: LabeledTextEntryView = {
		let view = LabeledTextEntryView(frame: .zero)
		view.textField.placeholder = "80"
		view.textLabel.text = "mmHg"
		return view
	}()

	let valuesStackView: OCKStackView = {
		let view = OCKStackView()
		view.axis = .horizontal
		view.distribution = .fillEqually
		view.alignment = .fill
		view.spacing = 22.0
		return view
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
		[leadingEntryView, trailingEntryView, valuesStackView].forEach { view in
			view.translatesAutoresizingMaskIntoConstraints = false
		}

		addSubview(valuesStackView)
		NSLayoutConstraint.activate([valuesStackView.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 0.0),
		                             valuesStackView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 22.0 / 8.0),
		                             trailingAnchor.constraint(equalToSystemSpacingAfter: valuesStackView.trailingAnchor, multiplier: 22.0 / 8.0),
		                             bottomAnchor.constraint(equalToSystemSpacingBelow: valuesStackView.bottomAnchor, multiplier: 0.0)])
		valuesStackView.addArrangedSubview(leadingEntryView)
		valuesStackView.addArrangedSubview(trailingEntryView)
	}
}
