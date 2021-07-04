//
//  ConnectProviderViewController.swift
//  Allie
//
//  Created by Waqar Malik on 6/24/21.
//

import UIKit

class ConnectProviderViewController: UIViewController {
	var showProviderList: AllieVoidCompletion?

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .allieWhite
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(titleLabel)
		NSLayoutConstraint.activate([titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 3.0),
		                             titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: titleLabel.trailingAnchor, multiplier: 2.0)])

		containerView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(containerView)
		NSLayoutConstraint.activate([containerView.topAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 6.0),
		                             containerView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: containerView.trailingAnchor, multiplier: 2.0)])
		connectView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(connectView)
		NSLayoutConstraint.activate([connectView.topAnchor.constraint(equalToSystemSpacingBelow: containerView.topAnchor, multiplier: 2.0),
		                             connectView.leadingAnchor.constraint(equalToSystemSpacingAfter: containerView.leadingAnchor, multiplier: 2.0),
		                             containerView.trailingAnchor.constraint(equalToSystemSpacingAfter: connectView.trailingAnchor, multiplier: 2.0),
		                             containerView.bottomAnchor.constraint(equalToSystemSpacingBelow: connectView.bottomAnchor, multiplier: 2.0)])
		connectView.connectButton.addTarget(self, action: #selector(showProviderSelector(_:)), for: .touchUpInside)
	}

	let titleLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.textAlignment = .center
		label.text = NSLocalizedString("WELCOME_TO_ALLIE", comment: "Welcome to Allie")
		label.textColor = .allieGray
		label.font = UIFont.systemFont(ofSize: 20.0, weight: .bold)
		return label
	}()

	let containerView: UIView = {
		let view = UIView(frame: .zero)
		view.backgroundColor = .allieWhite
		view.heightAnchor.constraint(equalToConstant: 380.0).isActive = true
		view.layer.cornerCurve = .continuous
		view.layer.cornerRadius = 11.0
		view.layer.shadowColor = UIColor.black.cgColor
		view.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
		view.layer.shadowRadius = 5.0
		view.layer.shadowOpacity = 0.2
		view.layer.masksToBounds = false
		return view
	}()

	let connectView: ConnectProviderView = {
		let view = ConnectProviderView(frame: .zero)
		view.axis = .vertical
		view.distribution = .fill
		view.alignment = .fill
		return view
	}()

	@objc func showProviderSelector(_ sender: Any?) {
		showProviderList?()
	}
}
