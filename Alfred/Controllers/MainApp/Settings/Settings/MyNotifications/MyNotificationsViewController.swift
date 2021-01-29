//
//  MyNotificationsViewController.swift
//  Alfred
//

import Foundation
import UIKit

class MyNotificationsViewController: BaseViewController {
	// MARK: Coordinator Actions

	var backBtnAction: (() -> Void)?

	// MARK: - Properties

	var notificationsSettings: [MyNotifications] = MyNotifications.allValues
	let rowHeight: CGFloat = 60

	// MARK: - IBOutlets

	@IBOutlet var myNotificationsTV: UITableView!

	// MARK: - Setup

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func setupView() {
		super.setupView()

		title = Str.myNotifications

		myNotificationsTV.register(UINib(nibName: SettingsSwitchCell.nibName, bundle: nil), forCellReuseIdentifier: SettingsSwitchCell.reuseIdentifier)
		myNotificationsTV.rowHeight = rowHeight
		myNotificationsTV.dataSource = self
		myNotificationsTV.delegate = self
		myNotificationsTV.isScrollEnabled = true
		myNotificationsTV.layoutMargins = UIEdgeInsets.zero
		myNotificationsTV.separatorInset = UIEdgeInsets.zero
		myNotificationsTV.tableFooterView = UIView()
		myNotificationsTV.separatorStyle = .singleLine
		myNotificationsTV.allowsSelection = false
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}

	override func populateData() {
		super.populateData()
	}

	// MARK: - Actions

	@objc func backBtnTapped() {
		backBtnAction?()
	}
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension MyNotificationsViewController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		notificationsSettings.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: SettingsSwitchCell.reuseIdentifier, for: indexPath) as? SettingsSwitchCell
		cell?.layoutMargins = UIEdgeInsets.zero

		cell?.setup(type: notificationsSettings[indexPath.row])
		return cell!
	}
}
