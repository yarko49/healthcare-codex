//
//  DevicesViewController.swift
//  Allie
//
//  Created by Waqar Malik on 3/20/21.
//

import Combine
import CoreBluetooth
import UIKit

class DevicesSelectionViewController: SignupBaseViewController, UITableViewDelegate {
	var nextButtonAction: AllieActionHandler?
	var dataSource: UITableViewDiffableDataSource<SectionType, String>!
	@Injected(\.bluetoothManager) var bluetoothManager: BGMBluetoothManager

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
		bottomButton.backgroundColor = .allieGray
		bottomButton.isHidden = controllerViewMode == .settings

		let detailText = NSLocalizedString("DEVICES_MESSAGE", comment: "Please select the types of smart devices you may have so Allie can automatically read measurements.")
		let strLength = detailText.count
		let style = NSMutableParagraphStyle()
		style.lineSpacing = 4
		style.alignment = .center
		let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 20.0, weight: .regular), .foregroundColor: UIColor.allieGray, .kern: NSNumber(-0.32)]
		let attributedString = NSMutableAttributedString(string: detailText, attributes: attributes)
		attributedString.addAttribute(.paragraphStyle, value: style, range: NSRange(location: 0, length: strLength))
		subtitleLabel.attributedText = attributedString
		subtitleLabel.isHidden = false
		if controllerViewMode == .onboarding {
			titleLabel.text = NSLocalizedString("DEVICES", comment: "Devices")
		} else {
			title = NSLocalizedString("DEVICES", comment: "Devices")
		}

		let viewTopAnchor = controllerViewMode == .onboarding ? labekStackView.bottomAnchor : view.safeAreaLayoutGuide.topAnchor
		let viewTopOffset: CGFloat = controllerViewMode == .onboarding ? 8.0 : 0.0
		NSLayoutConstraint.activate([tableView.topAnchor.constraint(equalToSystemSpacingBelow: viewTopAnchor, multiplier: viewTopOffset),
		                             tableView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 0.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: tableView.trailingAnchor, multiplier: 0.0),
		                             bottomButton.topAnchor.constraint(equalToSystemSpacingBelow: tableView.bottomAnchor, multiplier: 2.0)])

		tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reuseIdentifier)
		tableView.register(DevicesSelectionHeaderView.self, forHeaderFooterViewReuseIdentifier: DevicesSelectionHeaderView.reuseIdentifier)
		dataSource = UITableViewDiffableDataSource<SectionType, String>(tableView: tableView, cellProvider: { [weak self] tableView, indexPath, itemIdentifier in
			let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reuseIdentifier, for: indexPath)
			if let sections = self?.dataSource.snapshot().sectionIdentifiers, sections[indexPath.section] == .bluetooth {
				self?.configure(connected: cell, at: indexPath, itemIdentifier: itemIdentifier)
			} else {
				self?.configure(regular: cell, at: indexPath, itemIdentifier: itemIdentifier)
			}
			return cell
		})
		tableView.dataSource = dataSource
		tableView.delegate = self
		tableView.rowHeight = 48.0
		tableView.sectionHeaderHeight = DevicesSelectionHeaderView.height
		var snapshot = NSDiffableDataSourceSnapshot<SectionType, String>()
		snapshot.appendSections([.regular, .bluetooth])
		let identifiers = SmartDeviceType.allCases.map { deviceType in
			deviceType.rawValue
		}
		snapshot.appendItems(identifiers, toSection: .regular)
		dataSource.apply(snapshot, animatingDifferences: false) {
			ALog.info("Did finish applying snapshot")
		}
		tableView.isScrollEnabled = false
		if controllerViewMode != .onboarding {
			bluetoothManager.$peripherals
				.receive(on: RunLoop.main)
				.sink { [weak self] devices in
					guard !devices.isEmpty else {
						return
					}
					self?.updateConnected(devices: devices)
				}.store(in: &cancellables)
		}
	}

	private func configure(regular cell: UITableViewCell, at indexPath: IndexPath, itemIdentifier: String) {
		let accessoryView = UISwitch(frame: .zero)
		accessoryView.addTarget(self, action: #selector(didSelectSwitch(_:forEvent:)), for: .valueChanged)
		let deviceType = SmartDeviceType(rawValue: itemIdentifier)
		accessoryView.isOn = deviceType?.hasSmartDevice ?? false
		accessoryView.tag = indexPath.row
		cell.accessoryView = accessoryView
		cell.textLabel?.attributedText = deviceType?.title.attributedString(style: .regular17, foregroundColor: UIColor.grey, letterSpacing: -0.41)
	}

	private func configure(connected cell: UITableViewCell, at indexPath: IndexPath, itemIdentifier: String) {
		var isOn = false
		if let identifier = bluetoothManager.pairedPeripheral?.identifier.uuidString, identifier == itemIdentifier {
			isOn = true
		}
		let accessoryView = UISwitch(frame: .zero)
		accessoryView.addTarget(self, action: #selector(didSelectConnect(_:forEvent:)), for: .valueChanged)
		accessoryView.isOn = isOn
		accessoryView.tag = indexPath.row
		cell.accessoryView = accessoryView
		let peripheral = bluetoothManager.peripherals.first { peripheral in
			peripheral.identifier.uuidString == itemIdentifier
		}
		cell.textLabel?.attributedText = peripheral?.name?.attributedString(style: .regular17, foregroundColor: UIColor.grey, letterSpacing: -0.41)
	}

	private func updateConnected(devices: Set<CBPeripheral>) {
		var snapshot = dataSource.snapshot()
		let sections = snapshot.sectionIdentifiers
		if !sections.contains(.bluetooth) {
			snapshot.appendSections([.bluetooth])
		} else {
			let identifiers = snapshot.itemIdentifiers(inSection: .bluetooth)
			if !identifiers.isEmpty {
				snapshot.deleteItems(identifiers)
			}
		}
		snapshot.appendItems(devices.map { device in
			device.identifier.uuidString
		}, toSection: .bluetooth)
		dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
	}

	enum SectionType: String, Hashable {
		case regular
		case bluetooth

		var title: String? {
			switch self {
			case .regular:
				return NSLocalizedString("YOUR_DEVICES", comment: "Your Devices")
			case .bluetooth:
				return NSLocalizedString("CONNECTED_DEVICES", comment: "Connected Devices")
			}
		}
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
		guard let identifier = dataSource.itemIdentifier(for: indexPath) else {
			return
		}
		var device = SmartDeviceType(rawValue: identifier)
		device?.hasSmartDevice.toggle()
	}

	@IBAction func didSelectConnect(_ sender: UISwitch, forEvent event: UIEvent) {
		let indexPath = IndexPath(row: sender.tag, section: 1)
		let itemIdentifier = dataSource.itemIdentifier(for: indexPath)
		if let pairedIdentifier = UserDefaults.standard.bloodGlucoseMonitor?.localIdentifier {
			if itemIdentifier == pairedIdentifier {
				showUnpairAlert()
			} else {
				showCannotPair()
			}
		} else if let identifier = itemIdentifier {
			showBluetoothPairFlow(identifier: identifier)
		}
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

	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: DevicesSelectionHeaderView.reuseIdentifier) as? DevicesSelectionHeaderView
		let sectionIdentifier = dataSource.snapshot().sectionIdentifiers[section]
		headerView?.titleLabel.text = sectionIdentifier.title
		let sections = dataSource.snapshot().sectionIdentifiers
		if sections[section] == .bluetooth {
			headerView?.isAddButtonHidden = false
			headerView?.delegate = self
		}
		return headerView
	}

	func showUnpairAlert() {
		let title = NSLocalizedString("UNPAIR_DEVICE", comment: "Would you like to unpair this device?")
		let message = NSLocalizedString("UNPAIR_DEVICE.message", comment: "Your device will be disconnected and will not stream data into your Allie account.")
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Cancel"), style: .cancel, handler: nil)
		alertController.addAction(cancelAction)
		let unpairAction = UIAlertAction(title: NSLocalizedString("UNPAIR", comment: "Unpair"), style: .destructive) { _ in
			UserDefaults.standard.bloodGlucoseMonitor = nil
		}
		alertController.addAction(unpairAction)
		(tabBarController ?? navigationController ?? self).showDetailViewController(alertController, sender: self)
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
}

extension DevicesSelectionViewController: DevicesSelectionHeaderViewDelegate {
	func devicesSelectionHeaderViewDidSelectAdd(_ view: DevicesSelectionHeaderView) {
		showBluetoothPairFlow(identifier: nil)
	}

	func showBluetoothPairFlow(identifier: String?) {
		let viewController = BGMPairingViewController()
		viewController.modalPresentationStyle = .fullScreen
		viewController.delegate = self
		viewController.selectedIdentifier = identifier
		(tabBarController ?? navigationController ?? self).showDetailViewController(viewController, sender: self)
	}
}

extension DevicesSelectionViewController: BGMPairingViewControllerDelegate {
	func pairingViewControllerDidCancel(_ controller: BGMPairingViewController) {
		controller.dismiss(animated: true, completion: nil)
	}

	func pairingViewControllerDidFinish(_ controller: BGMPairingViewController) {
		controller.dismiss(animated: true, completion: nil)
	}
}
