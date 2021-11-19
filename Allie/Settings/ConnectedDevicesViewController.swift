//
//  ConnectedDevicesViewController.swift
//  Allie
//
//  Created by Waqar Malik on 9/11/21.
//

import AuthenticationServices
import Combine
import JGProgressHUD
import UIKit

class ConnectedDevicesViewController: UITableViewController {
	enum SectionType: Hashable, CaseIterable {
		case bluetooth
		case cloudDevices

		var title: String? {
			switch self {
			case .bluetooth:
				return NSLocalizedString("BLUETOOTH_DEVICES", comment: "Bluetooth Devices")
			case .cloudDevices:
				return NSLocalizedString("CLOUD_DEVICES", comment: "Cloud Devices")
			}
		}
	}

	private let hud: JGProgressHUD = {
		let view = JGProgressHUD(style: .dark)
		view.vibrancyEnabled = true
		view.textLabel.text = NSLocalizedString("LOADING", comment: "Loading")
		return view
	}()

	@Injected(\.bluetoothManager) var bluetoothManager: BGMBluetoothManager
	@Injected(\.careManager) var careManager: CareManager
	@Injected(\.networkAPI) var networkAPI: AllieAPI
	private var cancellables: Set<AnyCancellable> = []

	var addBarButtonItem: UIBarButtonItem?
	var dataSource: UITableViewDiffableDataSource<SectionType, String>!
	override func viewDidLoad() {
		super.viewDidLoad()
		title = NSLocalizedString("CONNECTED_DEVICES", comment: "Connected Devices")
		addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showBluetoothPairFlow(_:)))
		navigationItem.rightBarButtonItem = addBarButtonItem
		tableView.register(ConnectedDevicesCell.self, forCellReuseIdentifier: ConnectedDevicesCell.reuseIdentifier)
		tableView.register(ConnectedDevicesSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: ConnectedDevicesSectionHeaderView.reuseIdentifier)

		dataSource = UITableViewDiffableDataSource<SectionType, String>(tableView: tableView, cellProvider: { [weak self] tableView, indexPath, itemIdentifier in
			let cell = tableView.dequeueReusableCell(withIdentifier: ConnectedDevicesCell.reuseIdentifier, for: indexPath) as? ConnectedDevicesCell
			self?.configure(connected: cell, at: indexPath, itemIdentifier: itemIdentifier)
			return cell
		})
		tableView.dataSource = dataSource
		tableView.delegate = self
		tableView.rowHeight = 54.0
		tableView.sectionHeaderHeight = 64.0
		tableView.separatorStyle = .none
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		var snapshot = NSDiffableDataSourceSnapshot<SectionType, String>()
		snapshot.appendSections([.bluetooth])
		if let identifier = careManager.patient?.bgmName {
			snapshot.appendItems([identifier], toSection: .bluetooth)
		}
		dataSource.apply(snapshot, animatingDifferences: animated) {
			ALog.info("Did finish applying snapshot")
		}

		fetchCloudDevices()
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

	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: ConnectedDevicesSectionHeaderView.reuseIdentifier) as? ConnectedDevicesSectionHeaderView
		let sectionIdentifier = dataSource.snapshot().sectionIdentifiers[section]
		view?.textLabel?.text = sectionIdentifier.title
		return view
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		defer {
			tableView.deselectRow(at: indexPath, animated: true)
		}
		let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
		switch section {
		case .bluetooth:
			showBluetoothDetailView()
		case .cloudDevices:
			let device = cloudDevices.devices[indexPath.row]
			if !cloudDevices.registrations.contains(device.id) {
				showCloudAuthorizationView(device: device)
			} else {
				showDisconnectDeviceAlert(device: device)
			}
		}
	}

	func showBluetoothDetailView() {
		guard let device = careManager.patient?.bgmName else {
			return
		}
		let viewController = BGMDeviceDetailViewController()
		viewController.device = device
		navigationController?.show(viewController, sender: self)
	}

	func showCloudAuthorizationView(device: CHCloudDevice) {
		guard let authURL = device.authURL else {
			return
		}

		let webViewController = WebAuthenticationViewController()
		webViewController.authURL = authURL
		webViewController.cloudEntity = device
		webViewController.delegate = self
		let navController = UINavigationController(rootViewController: webViewController)
		navigationController?.show(navController, sender: self)
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

	private func configure(connected cell: ConnectedDevicesCell?, at indexPath: IndexPath, itemIdentifier: String) {
		guard let cell = cell else {
			return
		}
		let sections = dataSource.snapshot().sectionIdentifiers
		if sections[indexPath.section] == .bluetooth {
			cell.accessoryType = .disclosureIndicator
			let name = bluetoothManager.peripherals.first { peripheral in
				peripheral.identifier.uuidString == itemIdentifier
			}?.name ?? careManager.patient?.bgmName
			cell.textLabel?.attributedText = name?.attributedString(style: .regular17, foregroundColor: UIColor.grey, letterSpacing: -0.41)
		} else {
			let device = cloudDevices.devices[indexPath.row]
			cell.accessoryType = .none
			if cloudDevices.registrations.contains(device.id) {
				cell.accessoryType = .checkmark
			}
			cell.textLabel?.attributedText = device.name.attributedString(style: .regular17, foregroundColor: UIColor.grey, letterSpacing: -0.41)
		}
	}

	var cloudDevices = CHCloudDevices() {
		didSet {
			updateDataSource(cloudDevices: cloudDevices)
		}
	}

	private func fetchCloudDevices() {
		networkAPI.getCloudDevices()
			.sinkOnMain { completionResult in
				if case .failure(let error) = completionResult {
					ALog.error("Unable to fetch cloud devices", error: error)
				}
			} receiveValue: { [weak self] newDevices in
				self?.cloudDevices = newDevices
			}.store(in: &cancellables)
	}

	private func updateDataSource(cloudDevices: CHCloudDevices) {
		var snapshot = dataSource.snapshot()
		snapshot.deleteSections([.cloudDevices])
		if !cloudDevices.devices.isEmpty {
			let identifiers = cloudDevices.devices.map { device in
				device.id
			}
			if !identifiers.isEmpty {
				snapshot.appendSections([.cloudDevices])
				snapshot.appendItems(identifiers, toSection: .cloudDevices)
			}
		}

		dataSource.apply(snapshot, animatingDifferences: true) { [weak self] in
			self?.tableView.reloadData()
			ALog.trace("Did finished applying cloud devices")
		}
	}

	private func upload(token: String?, state: String?, device: CHCloudDevice) {
		var updateDevice = device
		updateDevice.authorizationToken = token
		if let state = state {
			updateDevice.state = state
		}

		hud.show(in: navigationController?.view ?? view)
		networkAPI.postIntegrate(cloudDevice: updateDevice)
			.sinkOnMain { [weak self] completionResult in
				if case .failure(let error) = completionResult {
					ALog.error("Unable to register device \(device.name)", error: error)
					let okAction = AlertHelper.AlertAction(withTitle: String.ok)
					let title = NSLocalizedString("REGISTRATION_ERROR.title", comment: "Something went wrong!")
					let message = NSLocalizedString("REGISTRATION_ERROR_DEVICE.message", comment: "We are unable to register with your health care device at this time.")
					AlertHelper.showAlert(title: title, detailText: message, actions: [okAction], from: self?.navigationController)
				}
				self?.hud.dismiss()
			} receiveValue: { [weak self] success in
				guard let strongSelf = self else {
					return
				}
				if success {
					let updatedDevices = CHCloudDevices(devices: strongSelf.cloudDevices.devices, registrations: [updateDevice.id])
					strongSelf.cloudDevices = updatedDevices
				}
			}.store(in: &cancellables)
	}

	private func showDisconnectDeviceAlert(device: CHCloudDevice) {
		let title = NSLocalizedString("DISCONNECT", comment: "Disconnect")
		let message = NSLocalizedString("DISCONNECT.message", comment: "Are you sure you want to disconnect") + " \(device.name)?"
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Cancel"), style: .cancel) { _ in
		}
		alertController.addAction(cancelAction)
		let disconnectAction = UIAlertAction(title: NSLocalizedString("DISCONNECT", comment: "Disconnect"), style: .destructive) { [weak self] _ in
			self?.disconnectCloudDevice(device: device)
		}
		alertController.addAction(disconnectAction)
		navigationController?.present(alertController, animated: true, completion: nil)
	}

	private func disconnectCloudDevice(device: CHCloudDevice) {
		hud.show(in: navigationController?.view ?? view)
		networkAPI.deleteIntegration(cloudDevice: device)
			.sinkOnMain { [weak self] completionResult in
				if case .failure(let error) = completionResult {
					ALog.error("Unable to deregister cloud device \(device.name)", error: error)
				}
				self?.hud.dismiss()
			} receiveValue: { [weak self] success in
				guard let strongSelf = self else {
					return
				}
				if success {
					var registrations = strongSelf.cloudDevices.registrations
					registrations.remove(device.id)
					let updatedDevices = CHCloudDevices(devices: strongSelf.cloudDevices.devices, registrations: registrations)
					strongSelf.cloudDevices = updatedDevices
				}
			}.store(in: &cancellables)
	}

	func showAppleWebAuthentication(device: CHCloudDevice) {
		guard let authURL = device.authURL, let redirectURI = authURL.extractRedirectURI else {
			return
		}
		let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: redirectURI) { callbackURL, error in
			guard error == nil, let successURL = callbackURL else {
				return
			}

			let oauthToken = URLComponents(string: successURL.absoluteString)?.queryItems?.filter { $0.name == "code" }.first?.value ?? "No OAuth Token"

			ALog.info("\(oauthToken)")
		}
		session.presentationContextProvider = self
		session.prefersEphemeralWebBrowserSession = true
		session.start()
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

extension ConnectedDevicesViewController: WebAuthenticationViewControllerDelegate {
	func webAuthenticationViewControllerDidCancel(_ controller: WebAuthenticationViewController) {
		controller.dismiss(animated: true, completion: nil)
	}

	func webAuthenticationViewController(_ controller: WebAuthenticationViewController, didFinsihWith token: String?, state: String?) {
		controller.dismiss(animated: true) {
			guard let token = token, let device = controller.cloudEntity as? CHCloudDevice else {
				return
			}
			self.upload(token: token, state: state, device: device)
		}
	}
}

extension ConnectedDevicesViewController: ASWebAuthenticationPresentationContextProviding {
	func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
		view.window ?? ASPresentationAnchor()
	}
}
