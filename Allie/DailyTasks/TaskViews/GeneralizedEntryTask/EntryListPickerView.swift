//
//  EntryListPickerView.swift
//  Allie
//
//  Created by Waqar Malik on 10/26/21.
//

import UIKit

protocol EntryListPickerViewDelegate: AnyObject {
	func entryListPickerViewDidSelectShow(_ view: EntryListPickerView)
}

class EntryListPickerView: UIView {
	class var height: CGFloat {
		48.0
	}

	class var reuseIdentifier: String {
		String(describing: self)
	}

	weak var delegate: EntryListPickerViewDelegate?

	let arrowIconView: UIImageView = {
		let view = UIImageView(frame: .zero)
		view.contentMode = .center
		view.image = UIImage(named: "icon-menu-down")
		return view
	}()

	var selectedValue: String? {
		get {
			actionButton.title(for: .normal)
		}
		set {
			actionButton.setTitle(newValue, for: .normal)
		}
	}

	let actionButton: UIButton = {
		let view = UIButton(type: .custom)
		view.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
		view.setTitle(NSLocalizedString("SELECT", comment: "Select"), for: .normal)
		view.setTitleColor(.allieBlack, for: .normal)
		view.contentHorizontalAlignment = .left
		view.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 15, bottom: 0.0, right: 25)
		view.layer.borderColor = UIColor.allieLightGray.withAlphaComponent(0.5).cgColor
		view.layer.borderWidth = 1.0
		view.layer.cornerRadius = 8.0
		view.layer.cornerCurve = .continuous
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

	func commonInit() {
		[arrowIconView, actionButton].forEach { view in
			view.translatesAutoresizingMaskIntoConstraints = false
			addSubview(view)
		}

		NSLayoutConstraint.activate([actionButton.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 0.0),
		                             actionButton.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 22.0 / 8.0),
		                             trailingAnchor.constraint(equalToSystemSpacingAfter: actionButton.trailingAnchor, multiplier: 22.0 / 8.0),
		                             bottomAnchor.constraint(equalToSystemSpacingBelow: actionButton.bottomAnchor, multiplier: 0.0)])

		NSLayoutConstraint.activate([arrowIconView.widthAnchor.constraint(equalToConstant: 6.0), arrowIconView.heightAnchor.constraint(equalToConstant: 9.0),
		                             arrowIconView.centerYAnchor.constraint(equalTo: actionButton.centerYAnchor), actionButton.trailingAnchor.constraint(equalToSystemSpacingAfter: arrowIconView.trailingAnchor, multiplier: 22.0 / 8.0)])
		actionButton.addTarget(self, action: #selector(didSelect(_:)), for: .touchUpInside)
	}

	@IBAction func didSelect(_ sender: Any) {
		delegate?.entryListPickerViewDidSelectShow(self)
	}
}
