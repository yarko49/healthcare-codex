//
//  PairingViewController.swift
//  Allie
//
//  Created by Waqar Malik on 1/12/22.
//

import BluetoothService
import CodexFoundation
import CoreBluetooth
import UIKit

protocol PairingViewControllerDelegate: AnyObject {
	func pairingViewControllerDidCancel(_ controller: PairingViewController)
	func pairingViewControllerDidFinish(_ controller: PairingViewController)
}

class PairingViewController: UIViewController, BluetoothServiceDelegate, PeripheralDelegate {
	weak var delegate: PairingViewControllerDelegate?
	var selectedIdentifier: String?
	@Injected(\.bluetoothService) var bluetoothService: BluetoothService
	@Injected(\.careManager) var careManager: CareManager
	var initialIndex: Int = 0
	var viewModel = PairingViewModel(pages: PairingItem.bloodGlucoseItems)
	var bluetoothDevices: [UUID: Peripheral] = [:]
	var dicoveryServices: [CBUUID] {
		[]
	}

	var measurementCharacteristics: [CBUUID] {
		[]
	}

	var isPairing: Bool = false
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .allieWhite
		pageViewController.dataSource = viewModel
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

		bluetoothService.addDelegate(self)
		bluetoothService.startMonitoring()
	}

	deinit {
		bluetoothService.removeDelegate(self)
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
		label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
		label.text = NSLocalizedString("BLUETOOTH_PAIRING", comment: "Bluetooth Pairing")
		label.textColor = .allieGray
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

	func configureView() {
		[titleLabel, cancelButton, continueButton].forEach { view in
			view.translatesAutoresizingMaskIntoConstraints = false
		}

		view.addSubview(cancelButton)
		NSLayoutConstraint.activate([cancelButton.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2.0),
		                             cancelButton.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1.0)])

		view.addSubview(titleLabel)
		NSLayoutConstraint.activate([titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: cancelButton.trailingAnchor, multiplier: 1.0),
		                             view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: titleLabel.trailingAnchor, multiplier: 10.5),
		                             titleLabel.centerYAnchor.constraint(equalTo: cancelButton.centerYAnchor)])

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
		if item.id == "success" || item.id == "failure" {
			delegate?.pairingViewControllerDidFinish(self)
		} else {
			scrollToNextPage(animated: true) { _ in
				ALog.info("Did Scroll To Page")
			}
		}
	}

	var currentPageViewController: PairingPageViewController? {
		pageViewController.viewControllers?.first as? PairingPageViewController
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
		pageViewController.setViewControllers([viewController], direction: direction, animated: animated) { result in
			completion?(result)
		}
	}

	func bluetoothService(_ service: BluetoothService, didUpdate state: CBManagerState) {
		if state == .poweredOn {
			ALog.info("Bluetooth Active")
			if !dicoveryServices.isEmpty {
				bluetoothService.scanForPeripherals(services: dicoveryServices)
			}
			ALog.info("Starting BLE scan\n")
		} else {
			ALog.error("Bluetooth State \(state.rawValue)")
		}
	}

	func bluetoothService(_ service: BluetoothService, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
		guard bluetoothDevices[peripheral.identifier] == nil else {
			return
		}
		let device = Peripheral(peripheral: peripheral, advertisementData: AdvertisementData(advertisementData: advertisementData), rssi: RSSI)
		device.delegate = self
		bluetoothDevices[device.identifier] = device
		DispatchQueue.main.async { [weak self] in
			self?.scroll(toPage: 2, direction: .forward, animated: true) { finished in
				ALog.info("Bluetooth Finished Scrolling to pairing \(finished)")
				ALog.info("Bluetooth Connecting to")
				service.connect(peripheral: peripheral)
			}
		}
	}

	func bluetoothService(_ service: BluetoothService, didConnect peripheral: CBPeripheral) {
		ALog.info("\(#function) \(peripheral)")
		guard let device = bluetoothDevices[peripheral.identifier] else {
			return
		}
		device.discoverServices(dicoveryServices)
	}

	func bluetoothService(_ service: BluetoothService, didFailToConnect peripheral: CBPeripheral, error: Error?) {
		bluetoothDevices.removeValue(forKey: peripheral.identifier)
		service.startMonitoring()
	}

	func bluetoothService(_ service: BluetoothService, didDisconnect peripheral: CBPeripheral, error: Error?) {
		bluetoothDevices.removeValue(forKey: peripheral.identifier)
		service.startMonitoring()
	}

	func peripheral(_ peripheral: Peripheral, didDiscoverServices services: [CBService], error: Error?) {
		for service in services {
			peripheral.discover(characteristics: measurementCharacteristics, for: service)
		}
	}

	func showSuccess() {
		viewModel.updateSuccess()
		continueButton.setTitle(NSLocalizedString("DONE", comment: "Done"), for: .normal)
		scrollToNextPage(animated: true)
	}

	func showFailure() {
		viewModel.updateFailure()
		continueButton.setTitle(NSLocalizedString("DONE", comment: "Done"), for: .normal)
		scrollToNextPage(animated: true)
	}

	func peripheral(_ peripheral: Peripheral, readyWith characteristic: CBCharacteristic) {
		peripheral.writeMessage(characteristic: characteristic, message: [], isBatched: true)
	}

	func peripheral(_ peripheral: Peripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
		processValue(peripheral: peripheral, characteristic: characteristic, error: error)
	}

	func peripheral(_ peripheral: Peripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
		processValue(peripheral: peripheral, characteristic: characteristic, error: error)
	}

	func processValue(peripheral: Peripheral, characteristic: CBCharacteristic, error: Error?) {
		isPairing = false
		if let error = error {
			ALog.error("pairing device", error: error)
			let nsError = error as NSError
			ALog.error("nsError = \(nsError)")
			if nsError.code == 15 || nsError.code == 3, nsError.domain == "CBATTErrorDomain" {
				bluetoothService.removeDelegate(self)
				DispatchQueue.main.async { [weak self] in
					self?.showFailure()
				}
			}
		} else {
			bluetoothService.removeDelegate(self)
			bluetoothService.stopMonitoring()
			updatePatient(peripheral: peripheral)
			DispatchQueue.main.async { [weak self] in
				self?.showSuccess()
			}
		}
	}

	func updatePatient(peripheral: Peripheral) {}
}
