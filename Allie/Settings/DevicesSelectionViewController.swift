//
//  DevicesViewController.swift
//  Allie
//
//  Created by Waqar Malik on 3/20/21.
//

import UIKit

class DevicesSelectionViewController: SignupBaseViewController, UITableViewDelegate {
	var nextButtonAction: Coordinable.ActionHandler?

	var dataSource: UITableViewDiffableDataSource<Int, SmartDeviceType>!

	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(tableView)
		view.addSubview(bottomButton)
		NSLayoutConstraint.activate([bottomButton.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: bottomButton.trailingAnchor, multiplier: 2.0),
		                             view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: bottomButton.bottomAnchor, multiplier: 2.0)])
		bottomButton.setTitle(NSLocalizedString("NEXT", comment: "Next"), for: .normal)
		bottomButton.addTarget(self, action: #selector(didSelectNext(_:)), for: .touchUpInside)
		bottomButton.isEnabled = true
		bottomButton.backgroundColor = .allieButtons
		bottomButton.isHidden = controllerViewMode == .settings

		titleLabel.text = NSLocalizedString("DEVICES", comment: "Devices")
		let viewTopAnchor = controllerViewMode == .onboarding ? titleLabel.bottomAnchor : view.safeAreaLayoutGuide.topAnchor
		let viewTopOffset: CGFloat = controllerViewMode == .onboarding ? 8.0 : 0.0
		NSLayoutConstraint.activate([tableView.topAnchor.constraint(equalToSystemSpacingBelow: viewTopAnchor, multiplier: viewTopOffset),
		                             tableView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 0.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: tableView.trailingAnchor, multiplier: 0.0),
		                             bottomButton.topAnchor.constraint(equalToSystemSpacingBelow: tableView.bottomAnchor, multiplier: 2.0)])

		tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reuseIdentifier)
		dataSource = UITableViewDiffableDataSource<Int, SmartDeviceType>(tableView: tableView, cellProvider: { [weak self] tableView, indexPath, deviceType in
			let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reuseIdentifier, for: indexPath)
			let accessoryView = UISwitch(frame: .zero)
			accessoryView.addTarget(self, action: #selector(self?.didSelectSwitch(_:forEvent:)), for: .valueChanged)
			accessoryView.isOn = deviceType.hasSmartDevice
			accessoryView.tag = indexPath.row
			cell.accessoryView = accessoryView
			cell.textLabel?.attributedText = deviceType.title.attributedString(style: .regular17, foregroundColor: UIColor.grey, letterSpacing: -0.41)
			return cell
		})
		tableView.dataSource = dataSource
		tableView.delegate = self
		tableView.rowHeight = 48.0
		var snapshot = NSDiffableDataSourceSnapshot<Int, SmartDeviceType>()
		snapshot.appendSections([0])
		snapshot.appendItems(SmartDeviceType.allCases)
		dataSource.apply(snapshot, animatingDifferences: false) {
			ALog.info("Did finish applying snapshot")
		}
		tableView.isScrollEnabled = false
	}

	let tableView: UITableView = {
		let view = UITableView(frame: .zero, style: .plain)
		view.isScrollEnabled = true
		view.layoutMargins = UIEdgeInsets.zero
		view.separatorInset = UIEdgeInsets.zero
		view.tableFooterView = UIView()
		view.separatorStyle = .singleLine
		view.allowsSelection = false
		return view
	}()

	@IBAction func didSelectNext(_ sender: UIButton) {
		nextButtonAction?()
	}

	@IBAction func didSelectSwitch(_ sender: UISwitch, forEvent event: UIEvent) {
		let indexPath = IndexPath(row: sender.tag, section: 0)
		var device = dataSource.itemIdentifier(for: indexPath)
		device?.hasSmartDevice.toggle()
	}

	func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		false
	}

	func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		nil
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
}
