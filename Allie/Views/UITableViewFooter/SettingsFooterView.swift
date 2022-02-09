//
//  SettingsFooterView.swift
//  Allie
//

import UIKit

protocol SettingsFooterViewDelegate: AnyObject {
	func settingsFooterViewDidTapLogout(_ view: SettingsFooterView)
	func settingsFooterViewDidTapDelete(_ view: SettingsFooterView)
}

class SettingsFooterView: UIView {
	@IBOutlet var contentView: UIView!

	// MARK: - IBOutlets

	let appVersionLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.text = "Version 00.001.0"
		label.textColor = .allieGray
		label.textAlignment = .center
		return label
	}()

	let logoutButton: BottomButton = {
		let button = BottomButton(frame: .zero)
		button.setTitle(NSLocalizedString("LOG_OUT", comment: "Log Out"), for: .normal)
		button.heightAnchor.constraint(equalToConstant: 48.0).isActive = true
		return button
	}()

	let deleteButton: BottomButton = {
		let button = BottomButton(frame: .zero)
		button.backgroundColor = .white
		button.layer.borderWidth = 1.0
		button.layer.borderColor = UIColor.allieRed.cgColor
		button.layer.cornerCurve = .continuous
		button.setTitle(NSLocalizedString("DELETE_ACCOUNT", comment: "Delete Account"), for: .normal)
		button.heightAnchor.constraint(equalToConstant: 48.0).isActive = true
		button.setTitleColor(.allieRed, for: .normal)
		return button
	}()

	private let stackView: UIStackView = {
		let view = UIStackView(frame: .zero)
		view.axis = .vertical
		view.distribution = .fill
		view.alignment = .fill
		view.spacing = 8.0
		return view
	}()

	weak var delegate: SettingsFooterViewDelegate?

	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func commonInit() {
		[appVersionLabel, logoutButton, deleteButton, stackView].forEach { view in
			view.translatesAutoresizingMaskIntoConstraints = false
		}
		addSubview(stackView)
        NSLayoutConstraint.activate([stackView.topAnchor.constraint(equalTo: topAnchor, constant: 100.0),
		                             stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 2.0),
		                             trailingAnchor.constraint(equalToSystemSpacingAfter: stackView.trailingAnchor, multiplier: 2.0),
		                             bottomAnchor.constraint(equalToSystemSpacingBelow: stackView.bottomAnchor, multiplier: 1.0)])
		[appVersionLabel, logoutButton, deleteButton].forEach { view in
			stackView.addArrangedSubview(view)
		}
		setup()

		logoutButton.addTarget(self, action: #selector(logoutAction(_:)), for: .touchUpInside)
		deleteButton.addTarget(self, action: #selector(deleteAction(_:)), for: .touchUpInside)
	}

	private func localize() {
		if let version = Bundle.main.ch_appVersion {
			appVersionLabel.attributedText = String.version(version).attributedString(style: .regular17, foregroundColor: UIColor.lightGrey, letterSpacing: -0.41)
		}
	}

	func setup() {
		localize()
		logoutButton.setupButton()
	}

	@IBAction func logoutAction(_ sender: Any) {
		delegate?.settingsFooterViewDidTapLogout(self)
	}

	@IBAction func deleteAction(_ sender: Any) {
		delegate?.settingsFooterViewDidTapDelete(self)
	}
}
