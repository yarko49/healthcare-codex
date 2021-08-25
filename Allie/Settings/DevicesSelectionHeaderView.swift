//
//  DevicesSelectionHeaderView.swift
//  Allie
//
//  Created by Waqar Malik on 8/16/21.
//

import UIKit

protocol DevicesSelectionHeaderViewDelegate: AnyObject {
	func devicesSelectionHeaderViewDidSelectAdd(_ view: DevicesSelectionHeaderView)
}

class DevicesSelectionHeaderView: UITableViewHeaderFooterView {
	class var height: CGFloat {
		54.0
	}

	weak var delegate: DevicesSelectionHeaderViewDelegate?

	private let stackView: UIStackView = {
		let view = UIStackView(frame: .zero)
		view.axis = .horizontal
		view.distribution = .fill
		view.alignment = .fill
		return view
	}()

	private let addButton: UIButton = {
		let button = UIButton(type: .system)
		button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
		button.tintColor = .allieGray
		button.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
		button.widthAnchor.constraint(equalToConstant: 44.0).isActive = true
		return button
	}()

	var isAddButtonHidden: Bool {
		get {
			addButton.isHidden
		}
		set {
			addButton.isHidden = newValue
		}
	}

	let titleLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.textColor = .allieGray
		label.font = UIFont.systemFont(ofSize: 17.0, weight: .semibold)
		label.textAlignment = .center
		return label
	}()

	override init(reuseIdentifier: String?) {
		super.init(reuseIdentifier: reuseIdentifier)
		commonInit()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		titleLabel.text = nil
		isAddButtonHidden = true
	}

	private func commonInit() {
		isAddButtonHidden = true
		[stackView, titleLabel, addButton].forEach { view in
			view.translatesAutoresizingMaskIntoConstraints = false
		}
		contentView.addSubview(stackView)
		let view = UIView(frame: .zero)
		view.backgroundColor = .white
		backgroundView = view
		NSLayoutConstraint.activate([stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 2.0),
		                             contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: stackView.trailingAnchor, multiplier: 2.0),
		                             stackView.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1.0),
		                             contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: stackView.bottomAnchor, multiplier: 1.0)])
		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(addButton)
		addButton.addTarget(self, action: #selector(didSelectAdd(_:)), for: .touchUpInside)
	}

	@IBAction func didSelectAdd(_ button: UIButton) {
		delegate?.devicesSelectionHeaderViewDidSelectAdd(self)
	}
}
