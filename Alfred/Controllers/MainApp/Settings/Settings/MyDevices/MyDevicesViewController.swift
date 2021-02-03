//
//  MyDevicesViewController.swift
//  Alfred
//

import Foundation
import HealthKit
import UIKit

class MyDevicesViewController: BaseViewController {
	// MARK: Coordinator Actions

	var profileRequestAction: (() -> Void)?

	// MARK: - Properties

	var devicesSettings: [DevicesSettings] = DevicesSettings.allValues
	let rowHeight: CGFloat = 60

	// MARK: - IBOutlets

	@IBOutlet var bottomView: UIView!
	@IBOutlet var nextBtn: BottomButton!
	@IBOutlet var devicesSettingsTV: UITableView!

	// MARK: - Setup

	override func setupView() {
		super.setupView()

		title = Str.myDevices
		nextBtn.setupButton()
		bottomView.backgroundColor = UIColor.next
		nextBtn.backgroundColor = UIColor.next
		nextBtn.setAttributedTitle(Str.next.uppercased().with(style: .regular17, andColor: .white, andLetterSpacing: 5), for: .normal)
		nextBtn.refreshCorners(value: 0)
		setupTableView()
	}

	func setupTableView() {
		devicesSettingsTV.register(UINib(nibName: SettingsSwitchCell.nibName, bundle: nil), forCellReuseIdentifier: SettingsSwitchCell.reuseIdentifier)
		devicesSettingsTV.rowHeight = rowHeight
		devicesSettingsTV.dataSource = self
		devicesSettingsTV.delegate = self
		devicesSettingsTV.isScrollEnabled = true
		devicesSettingsTV.layoutMargins = UIEdgeInsets.zero
		devicesSettingsTV.separatorInset = UIEdgeInsets.zero
		devicesSettingsTV.tableFooterView = UIView()
		devicesSettingsTV.separatorStyle = .singleLine
		devicesSettingsTV.allowsSelection = false
	}

	// MARK: - Actions

	@IBAction func nextBtnTapped(_ sender: Any) {
		profileRequestAction?()
	}

	@objc func allowDevices() {}
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension MyDevicesViewController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		devicesSettings.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: SettingsSwitchCell.reuseIdentifier, for: indexPath) as? SettingsSwitchCell
		cell?.layoutMargins = UIEdgeInsets.zero

		cell?.setup(type: devicesSettings[indexPath.row])
		return cell!
	}
}
