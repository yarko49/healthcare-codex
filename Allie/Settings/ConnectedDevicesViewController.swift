//
//  ConnectedDevicesViewController.swift
//  Allie
//
//  Created by Waqar Malik on 9/11/21.
//

import UIKit

class ConnectedDevicesViewController: UITableViewController {
	@Injected(\.bluetoothManager) var bluetoothManager: BGMBluetoothManager
	@Injected(\.careManager) var careManager: CareManager

	var addBarButtonItem: UIBarButtonItem?
	var dataSource: UITableViewDiffableDataSource<Int, String>!

	override func viewDidLoad() {
		super.viewDidLoad()
		title = NSLocalizedString("CONNECTED_DEVICES", comment: "Connected Devices")
		addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showBluetoothPairFlow(_:)))
		navigationItem.rightBarButtonItem = addBarButtonItem
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reuseIdentifier)

		dataSource = UITableViewDiffableDataSource<Int, String>(tableView: tableView, cellProvider: { [weak self] tableView, indexPath, itemIdentifier in
			let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reuseIdentifier, for: indexPath)
			self?.configure(connected: cell, at: indexPath, itemIdentifier: itemIdentifier)
			return cell
		})
		tableView.dataSource = dataSource
		tableView.delegate = self
		tableView.rowHeight = 54.0
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
		snapshot.appendSections([0])
		if let identifier = careManager.patient?.bgmName {
			snapshot.appendItems([identifier], toSection: 0)
		}
		dataSource.apply(snapshot, animatingDifferences: animated) {
			ALog.info("Did finish applying snapshot")
		}
	}

	@IBAction func showBluetoothPairFlow(_ sender: UIBarButtonItem?) {
		guard careManager.patient?.bgmName == nil else {
			showCannotPair()
			return
		}

		let viewController = BGMPairingViewController()
		viewController.modalPresentationStyle = .fullScreen
		viewController.delegate = self
		(tabBarController ?? navigationController ?? self).showDetailViewController(viewController, sender: self)
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		defer {
			tableView.deselectRow(at: indexPath, animated: true)
		}
		showUnpairView()
	}

	func showUnpairView() {
		guard let device = careManager.patient?.bgmName else {
			return
		}
		let viewController = BGMDeviceDetailViewController()
		viewController.device = device
		navigationController?.show(viewController, sender: self)
	}

	func showCannotPair() {
		let title = NSLocalizedString("BGM_CANNOT_PAIR", comment: "Cannot pair another device")
		let message = NSLocalizedString("BGM_CANNOT_PAIR.message", comment: "Only one device of this type can be paired at once. Please disconnect your previous device to connect this new one.")
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Ok"), style: .default) { _ in
		}
		alertController.addAction(okAction)
		(tabBarController ?? navigationController ?? self).showDetailViewController(alertController, sender: self)
	}

	private func configure(connected cell: UITableViewCell, at indexPath: IndexPath, itemIdentifier: String) {
		cell.accessoryType = .disclosureIndicator
		let name = bluetoothManager.peripherals.first { peripheral in
			peripheral.identifier.uuidString == itemIdentifier
		}?.name ?? careManager.patient?.bgmName
		cell.textLabel?.attributedText = name?.attributedString(style: .regular17, foregroundColor: UIColor.grey, letterSpacing: -0.41)
	}
}

extension ConnectedDevicesViewController: BGMPairingViewControllerDelegate {
	func pairingViewControllerDidCancel(_ controller: BGMPairingViewController) {
		controller.dismiss(animated: true, completion: nil)
	}

	func pairingViewControllerDidFinish(_ controller: BGMPairingViewController) {
		controller.dismiss(animated: true, completion: nil)
	}
}
