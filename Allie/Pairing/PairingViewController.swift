//
//  PairingViewController.swift
//  Allie
//
//  Created by Waqar Malik on 1/12/22.
//

import BluetoothService
import CodexFoundation
import CoreBluetooth
import OmronKit
import UIKit

protocol PairingViewControllerDelegate: AnyObject {
	func pairingViewControllerDidCancel(_ controller: PairingViewController)
	func pairingViewControllerDidFinish(_ controller: PairingViewController)
}

class PairingViewController: UIViewController, PeripheralDelegate, OHQDeviceManagerDelegate {
	weak var delegate: PairingViewControllerDelegate?
	var selectedIdentifier: String?
	@Injected(\.careManager) var careManager: CareManager
	@Injected(\.syncManager) var syncManager: BluetoothSyncManager

	var initialIndex: Int = 0
	var viewModel = PairingViewModel(pages: PairingItem.bloodGlucoseItems)
	var bluetoothDevices: [UUID: Peripheral] = [:]
	var deviceCategories: Set<OHQDeviceCategory> = [.any]

	var deviceManager: OHQDeviceManager {
		OHQDeviceManager.shared()
	}

	var dicoveryServices: [CBUUID] {
		[]
	}

	var measurementCharacteristics: [CBUUID] {
		[]
	}

	var isPairing: Bool = false
	override func viewDidLoad() {
		super.viewDidLoad()
		syncManager.stop()
		view.backgroundColor = .allieWhite
		pageViewController.dataSource = viewModel
		pageViewController.delegate = self
		pageViewController.isPagingEnabled = false
		pageViewController.view.frame = view.bounds
		let viewController = viewModel.viewControllerAt(index: initialIndex)
		pageViewController.setViewControllers([viewController!], direction: .forward, animated: false) { finished in
			ALog.info("Did finish setting view controller \(finished)")
		}
		addChild(pageViewController)
		view.addSubview(pageViewController.view)
		view.sendSubviewToBack(pageViewController.view)
		pageViewController.didMove(toParent: self)
		configureView()
		deviceManager.delegate = self
		currentPageDidChange(index: initialIndex)
	}

	deinit {
		syncManager.start()
	}

	var pageViewController: UIPageViewController = {
		let viewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
		return viewController
	}()

	let continueButton: UIButton = {
		let button = UIButton.grayButton
		button.setTitle(NSLocalizedString("CONTINUE", comment: "Continue"), for: .normal)
		button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .bold)
		button.heightAnchor.constraint(equalToConstant: 48.0).isActive = true
		button.setShadow()
		return button
	}()

	let titleLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
		label.text = NSLocalizedString("PAIRING", comment: "Pairing")
		label.textColor = .allieGray
		label.textAlignment = .center
		return label
	}()

	let deviceNameTitleLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.textColor = .allieGray
		label.numberOfLines = 0
		label.font = UIFont.systemFont(ofSize: 20.0, weight: .bold)
		label.textAlignment = .center
		label.text = NSLocalizedString("ACTIVE_DEVICES_NEAR_YOU", comment: "Active devices near you")
		return label
	}()

	let deviceNameLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.textColor = .allieGray
		label.numberOfLines = 0
		label.font = UIFont.systemFont(ofSize: 17.0, weight: .bold)
		label.textAlignment = .center
		return label
	}()

	let cancelButton: UIButton = {
		let button = UIButton(type: .system)
		let symbolConfig = UIImage.SymbolConfiguration(pointSize: 16.0, weight: .bold, scale: .medium)
		let image = UIImage(systemName: "multiply", withConfiguration: symbolConfig)
		button.setImage(image, for: .normal)
		button.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
		button.widthAnchor.constraint(equalToConstant: 44.0).isActive = true
		button.tintColor = .allieGray
		return button
	}()

	let deviceInfoStackView: UIStackView = {
		let view = UIStackView(frame: .zero)
		view.axis = .vertical
		view.spacing = 16.0
		view.distribution = .fill
		view.alignment = .fill
		return view
	}()

	func configureView() {
		[titleLabel, cancelButton, continueButton, deviceNameLabel, deviceNameTitleLabel, deviceInfoStackView].forEach { view in
			view.translatesAutoresizingMaskIntoConstraints = false
		}

		view.addSubview(cancelButton)
		NSLayoutConstraint.activate([cancelButton.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2.0),
		                             cancelButton.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1.0)])

		view.addSubview(titleLabel)
		NSLayoutConstraint.activate([titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: cancelButton.trailingAnchor, multiplier: 1.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: titleLabel.trailingAnchor, multiplier: 10.5),
		                             titleLabel.centerYAnchor.constraint(equalTo: cancelButton.centerYAnchor)])

		view.addSubview(deviceInfoStackView)
		NSLayoutConstraint.activate([deviceInfoStackView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: deviceInfoStackView.trailingAnchor, multiplier: 2.0),
		                             deviceInfoStackView.topAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 5.0)])
		deviceInfoStackView.addArrangedSubview(deviceNameTitleLabel)
		deviceInfoStackView.addArrangedSubview(deviceNameLabel)

		view.addSubview(continueButton)
		NSLayoutConstraint.activate([continueButton.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 3.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: continueButton.trailingAnchor, multiplier: 3.0),
		                             view.safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: continueButton.bottomAnchor, multiplier: 2.0)])

		continueButton.addTarget(self, action: #selector(didPressContinue(_:)), for: .touchUpInside)
		cancelButton.addTarget(self, action: #selector(cancel(_:)), for: .touchUpInside)
	}

	@IBAction func cancel(_ sender: UIButton) {
		delegate?.pairingViewControllerDidCancel(self)
	}

	@IBAction func didPressContinue(_ button: UIButton) {
		guard let item = currentPageViewController?.item else {
			return
		}
		switch item.id {
		case "success", "failure":
			delegate?.pairingViewControllerDidFinish(self)
		case "one":
			scrollToNextPage(animated: true) { _ in
				ALog.info("Did Scroll To Page")
			}
		case "two":
			startPairing()
		case "three":
			break
		default:
			break
		}
	}

	func currentPageDidChange(index: Int) {
		guard let identifier = viewModel.identifier(forPage: index) else {
			return
		}
		switch identifier {
		case "one":
			deviceInfoStackView.isHidden = true
			continueButton.setTitle(NSLocalizedString("CONTINUE", comment: "Continue"), for: .normal)
			setContinueButton(enabled: true)
		case "two":
			deviceInfoStackView.isHidden = false
			continueButton.setTitle(NSLocalizedString("START_PAIRING", comment: "Start Pairing"), for: .normal)
			if deviceNameLabel.text == nil {
				setContinueButton(enabled: false)
			}
		case "three":
			deviceInfoStackView.isHidden = true
			setContinueButton(enabled: false)
		case "success":
			deviceInfoStackView.isHidden = true
			continueButton.setTitle(NSLocalizedString("DONE", comment: "Done"), for: .normal)
			setContinueButton(enabled: true)
		case "failure":
			deviceInfoStackView.isHidden = true
			continueButton.setTitle(NSLocalizedString("DONE", comment: "Done"), for: .normal)
			setContinueButton(enabled: true)
		default:
			break
		}
	}

	func setContinueButton(enabled: Bool) {
		continueButton.isEnabled = enabled
		continueButton.backgroundColor = enabled ? .allieGray : .allieLighterGray
	}

	var currentPageViewController: PairingPageViewController? {
		pageViewController.viewControllers?.first as? PairingPageViewController
	}

	private(set) var currentPageIndex: Int = 0 {
		didSet {
			currentPageDidChange(index: currentPageIndex)
		}
	}

	func scrollToPage(identifier: String, animated: Bool, completion: ((Bool) -> Void)? = nil) {
		guard let index = viewModel.page(forIdentifier: identifier) else {
			completion?(false)
			return
		}

		scroll(toPage: index, direction: .forward, animated: true, completion: completion)
	}

	func scrollToNextPage(animated: Bool, completion: ((Bool) -> Void)? = nil) {
		guard let viewController = pageViewController.viewControllers?.first, let index = viewModel.firstIndex(of: viewController) else {
			completion?(false)
			return
		}

		scroll(toPage: index + 1, direction: .forward, animated: animated, completion: completion)
	}

	func scrollToPreviousPage(animated: Bool, completion: ((Bool) -> Void)? = nil) {
		guard let viewController = pageViewController.viewControllers?.first, let index = viewModel.firstIndex(of: viewController) else {
			completion?(false)
			return
		}

		scroll(toPage: index - 1, direction: .reverse, animated: animated, completion: completion)
	}

	func scroll(toPage page: Int, direction: UIPageViewController.NavigationDirection, animated: Bool, completion: ((Bool) -> Void)? = nil) {
		guard let viewController = viewModel.viewControllerAt(index: page) else {
			completion?(false)
			return
		}
		pageViewController.setViewControllers([viewController], direction: direction, animated: animated) { [weak self] result in
			if result {
				self?.currentPageIndex = page
			}
			completion?(result)
		}
	}

	// MARK: - PeripheralDelegate

	func showSuccess(completion: ((Bool) -> Void)? = nil) {
		viewModel.updateSuccess()
		continueButton.setTitle(NSLocalizedString("DONE", comment: "Done"), for: .normal)
		scrollToPage(identifier: "success", animated: true, completion: completion)
	}

	func showFailure(completion: ((Bool) -> Void)? = nil) {
		viewModel.updateFailure()
		continueButton.setTitle(NSLocalizedString("DONE", comment: "Done"), for: .normal)
		scrollToPage(identifier: "failure", animated: true, completion: completion)
	}

	func peripheral(_ peripheral: Peripheral, didDiscoverServices services: [CBService], error: Error?) {
		ALog.info("\(#function) services \(services)")

		for service in services {
			peripheral.discover(characteristics: measurementCharacteristics, for: service)
		}
	}

	func peripheral(_ peripheral: Peripheral, readyWith characteristic: CBCharacteristic) {
		ALog.info("\(#function) characteristic: \(characteristic)")
		peripheral.writeMessage(characteristic: characteristic, message: [], isBatched: true)
	}

	func peripheral(_ peripheral: Peripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
		ALog.info("\(#function) characteristic: \(characteristic)")
		// processValue(peripheral: peripheral, characteristic: characteristic, error: error)
	}

	func peripheral(_ peripheral: Peripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
		ALog.info("\(#function) characteristic: \(characteristic)")
		processValue(peripheral: peripheral, characteristic: characteristic, error: error)
	}

	func processValue(peripheral: Peripheral, characteristic: CBCharacteristic, error: Error?) {
		ALog.info("\(#function) characteristic: \(characteristic)")
		isPairing = false
		guard characteristic.uuid == GATTCurrentTime.uuid else {
			return
		}
		if let error = error {
			ALog.error("pairing device", error: error)
			let nsError = error as NSError
			ALog.error("nsError = \(nsError)")
			if nsError.code == 15 || nsError.code == 3, nsError.domain == "CBATTErrorDomain" {
				DispatchQueue.main.async { [weak self] in
					self?.showFailure()
				}
			}
		} else {
			DispatchQueue.main.async { [weak self] in
				self?.showSuccess(completion: { _ in
					self?.updatePatient(peripheral: peripheral)
				})
			}
		}
	}

	func updatePatient(peripheral: Peripheral) {}

	func startPairing() {
		ALog.info("\(#function) Bluetooth Connecting to")
		guard let device = bluetoothDevices.first?.value else {
			return
		}
		deviceManager.stopScan()
		deviceManager.connectPerpherial(device.peripheral, withOptions: nil)
		setContinueButton(enabled: false)
	}

	// MARK: - OHQDeviceManagerDelegate

	func deviceManager(_ manager: OHQDeviceManager, didConnect peripheral: CBPeripheral) {
		ALog.info("\(#function) \(peripheral)")
		guard let device = bluetoothDevices[peripheral.identifier] else {
			return
		}
		device.discoverServices(dicoveryServices)
	}

	func deviceManager(_ manager: OHQDeviceManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
		ALog.info("\(#function) \(peripheral) \(String(describing: error))")
		bluetoothDevices.removeValue(forKey: peripheral.identifier)
		DispatchQueue.main.async { [weak self] in
			self?.deviceNameLabel.text = nil
			self?.setContinueButton(enabled: false)
		}
		manager.startScan()
	}

	func deviceManager(_ manager: OHQDeviceManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
		ALog.info("\(#function) \(peripheral) \(String(describing: error))")
		bluetoothDevices.removeValue(forKey: peripheral.identifier)
		DispatchQueue.main.async { [weak self] in
			self?.deviceNameLabel.text = nil
			self?.setContinueButton(enabled: false)
		}
		manager.startScan()
	}

	func deviceManager(_ manager: OHQDeviceManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
		ALog.info("\(#function) \(peripheral), \(advertisementData)")
		guard bluetoothDevices[peripheral.identifier] == nil else {
			return
		}
		let discoveredCategory = manager.deviceInfo(for: peripheral)?.category ?? .unknown
		guard deviceCategories.contains(discoveredCategory), discoveredCategory != .unknown, discoveredCategory != .any else {
			return
		}
		let device = Peripheral(peripheral: peripheral, advertisementData: AdvertisementData(advertisementData: advertisementData), rssi: RSSI)
		device.delegate = self
		bluetoothDevices[device.identifier] = device
		ALog.info("\(#function) \(peripheral) Added to bluetoothDevices")
		DispatchQueue.main.async { [weak self] in
			guard let strongSelf = self else {
				return
			}
			strongSelf.deviceNameLabel.text = device.name
			strongSelf.setContinueButton(enabled: true)
			if strongSelf.currentPageIndex != 1 {
				strongSelf.scroll(toPage: 1, direction: strongSelf.currentPageIndex < 1 ? .forward : .reverse, animated: true, completion: nil)
			}
		}
	}
}

extension PairingViewController: UIPageViewControllerDelegate {
	func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		guard completed else {
			return
		}

		guard let viewController = pageViewController.viewControllers?.last else {
			return
		}

		guard let index = viewModel.firstIndex(of: viewController) else {
			return
		}

		currentPageIndex = index
	}
}
