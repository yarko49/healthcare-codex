//
//  EntryTaskSectionHeaderView.swift
//  Allie
//
//  Created by Waqar Malik on 7/9/21.
//

import CareKitUI
import UIKit

protocol EntryTaskSectionHeaderViewDelegate: AnyObject {
	func entryTaskSectionHeaderViewDidSelectButton(_ view: EntryTaskSectionHeaderView)
}

class EntryTaskSectionHeaderView: UICollectionReusableView {
	class var height: CGFloat {
		75.0 + 8.0
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}

	weak var delegate: EntryTaskSectionHeaderViewDelegate?

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	let imageView: UIImageView = {
		let view = UIImageView(frame: .zero)
		view.contentMode = .center
		view.heightAnchor.constraint(equalToConstant: 46.0).isActive = true
		view.widthAnchor.constraint(equalToConstant: 46.0).isActive = true
		return view
	}()

	let labelStackView: OCKStackView = {
		let stackView = OCKStackView()
		stackView.axis = .vertical
		stackView.distribution = .fill
		stackView.alignment = .leading
		stackView.spacing = 4.0
		return stackView
	}()

	let textLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.textAlignment = .center
		label.font = UIFont.systemFont(ofSize: 16.0, weight: .bold)
		label.textColor = .allieGray
		return label
	}()

	let detailTextLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.textAlignment = .center
		label.font = UIFont.systemFont(ofSize: 12.0, weight: .regular)
		label.textColor = .allieLighterGray
		label.numberOfLines = 2
		return label
	}()

	let button: UIButton = {
		let button = UIButton(type: .system)
		button.heightAnchor.constraint(equalToConstant: 46.0).isActive = true
		button.widthAnchor.constraint(equalToConstant: 46.0).isActive = true
		button.layer.cornerCurve = .continuous
		button.layer.cornerRadius = 23.0
		button.tintColor = .allieWhite
		return button
	}()

	let shadowView: GradientView = {
		let view = GradientView(frame: .zero)
		view.locations = [0.0, 1.0]
		view.type = .axial
		view.startPoint = CGPoint(x: 0.5, y: 0.0)
		view.endPoint = CGPoint(x: 0.5, y: 1.0)
		view.colors = [.black.withAlphaComponent(0.05), .clear]
		view.heightAnchor.constraint(equalToConstant: 5.0).isActive = true
		return view
	}()

	private func commonInit() {
		[imageView, labelStackView, textLabel, detailTextLabel, button].forEach { view in
			view.translatesAutoresizingMaskIntoConstraints = false
		}
		addSubview(imageView)
		NSLayoutConstraint.activate([imageView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 22.0 / 8.0),
		                             imageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0.0)])
		addSubview(labelStackView)
		NSLayoutConstraint.activate([labelStackView.leadingAnchor.constraint(equalToSystemSpacingAfter: imageView.trailingAnchor, multiplier: 15.0 / 8),
		                             labelStackView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)])
		labelStackView.addArrangedSubview(textLabel)
		labelStackView.addArrangedSubview(detailTextLabel)
		addSubview(button)
		NSLayoutConstraint.activate([button.leadingAnchor.constraint(equalToSystemSpacingAfter: labelStackView.trailingAnchor, multiplier: 15.0 / 8),
		                             button.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
		                             trailingAnchor.constraint(equalToSystemSpacingAfter: button.trailingAnchor, multiplier: 22.0 / 8.0)])
		shadowView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(shadowView)
		NSLayoutConstraint.activate([shadowView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 0.0),
		                             trailingAnchor.constraint(equalToSystemSpacingAfter: shadowView.trailingAnchor, multiplier: 0.0),
		                             bottomAnchor.constraint(equalToSystemSpacingBelow: shadowView.bottomAnchor, multiplier: 0.0)])
		button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
	}

	@objc func buttonAction(_ sender: Any?) {
		delegate?.entryTaskSectionHeaderViewDidSelectButton(self)
	}
}
