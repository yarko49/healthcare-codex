//
//  MyDevicesVC.swift
//  alfred-ios
//

import Foundation
import UIKit

class MyDevicesVC: BaseVC {
	// MARK: - Properties

	var devicesSettings: [DevicesSettings] = DevicesSettings.allValues
	let rowHeight: CGFloat = 80

	// MARK: - IBOutlets

	@IBOutlet var devicesTV: UITableView!

	// MARK: - Setup

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func setupView() {
		super.setupView()

		title = "Devices"

		devicesTV.register(UINib(nibName: "SettingsSwitchCell", bundle: nil), forCellReuseIdentifier: "SettingsSwitchCell")
		devicesTV.rowHeight = rowHeight
		devicesTV.dataSource = self
		devicesTV.delegate = self
		devicesTV.isScrollEnabled = true
		devicesTV.layoutMargins = UIEdgeInsets.zero
		devicesTV.separatorInset = UIEdgeInsets.zero
		devicesTV.tableFooterView = UIView()
		devicesTV.separatorStyle = .singleLine
		devicesTV.allowsSelection = false
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}

	override func populateData() {
		super.populateData()
	}

	// MARK: - Actions
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension MyDevicesVC: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		devicesSettings.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsSwitchCell", for: indexPath) as! SettingsSwitchCell
		cell.layoutMargins = UIEdgeInsets.zero

		cell.setup(name: devicesSettings[indexPath.row].description)
		return cell
	}
}
