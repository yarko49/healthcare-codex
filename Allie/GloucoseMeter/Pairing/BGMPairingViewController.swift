//
//  BGMPairingViewController.swift
//  Allie
//
//  Created by Waqar Malik on 8/23/21.
//

import CoreBluetooth
import UIKit

protocol BGMPairingViewControllerDelegate: AnyObject {
	func pairingViewControllerDidCancel(_ controller: BGMPairingViewController)
	func pairingViewControllerDidFinish(_ controller: BGMPairingViewController)
}

extension UIPageViewController {
	var isPagingEnabled: Bool {
		get {
			scrollView?.isScrollEnabled ?? false
		}
		set {
			scrollView?.isScrollEnabled = newValue
		}
	}

	var scrollView: UIScrollView? {
		view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView
	}
}

class BGMPairingViewController: UIViewController {
	weak var delegate: BGMPairingViewControllerDelegate?
	var initialIndex: Int = 0
	var selectedIdentifier: String?
	@Injected(\.bluetoothManager) var bluetoothManager: BGMBluetoothManager

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

	private let titleLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
		label.text = NSLocalizedString("BLUETOOTH_PAIRING", comment: "Bluetooth Pairing")
		label.textColor = .allieGray
		label.textAlignment = .center
		return label
	}()

	private let cancelButton: UIButton = {
		let button = UIButton(type: .system)
		let symbolConfig = UIImage.SymbolConfiguration(pointSize: 16.0, weight: .bold, scale: .medium)
		let image = UIImage(systemName: "multiply", withConfiguration: symbolConfig)
		button.setImage(image, for: .normal)
		button.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
		button.widthAnchor.constraint(equalToConstant: 44.0).isActive = true
		button.tintColor = .allieGray
		return button
	}()

	var viewModel = BGMPairingViewModel()

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
		pageViewController.didMove(toParent: self)
		// pageViewController.isPagingEnabled = false
		bluetoothManager.delegate = self
		bluetoothManager.startMonitoring()
		configureView()
	}

	private func configureView() {
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

	@IBAction private func didPressContinue(_ button: UIButton) {
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

	@IBAction private func cancel(_ sender: UIButton) {
		delegate?.pairingViewControllerDidCancel(self)
	}

	var currentPageViewController: BGMPairingPageViewController? {
		pageViewController.viewControllers?.first as? BGMPairingPageViewController
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
}

extension BGMPairingViewController: BGMBluetoothManagerDelegate {
	func bluetoothManager(_ manager: BGMBluetoothManager, didUpdate state: CBManagerState) {
		if state == .poweredOn {
			ALog.info("Bluetooth Active")
			bluetoothManager.scanForPeripherals()
			ALog.info("Starting BLE scan\n")
		} else {
			ALog.error("Bluetooth State \(state)")
		}
	}

	func bluetoothManager(_ manager: BGMBluetoothManager, didFindDevice peripheral: CBPeripheral, rssi: Int) {
		manager.peripherals.insert(peripheral)
		DispatchQueue.main.async { [weak self] in
			self?.scroll(toPage: 2, direction: .forward, animated: true) { finished in
				ALog.info("Bluetooth Finished Scrolling to pairing \(finished)")
				ALog.info("Bluetooth Connecting to")
				manager.connect(peripheral: peripheral)
			}
		}
	}

	func bluetoothManager(_ manager: BGMBluetoothManager, peripheral: CBPeripheral, readyWith characteristic: CBCharacteristic) {
		manager.writeMessage(peripheral: peripheral, characteristic: characteristic, message: BGMBluetoothManager.Command.numberOfRecords)
	}

	// didWriteValueFor: Error Domain=CBATTErrorDomain Code=15 "Encryption is insufficient." UserInfo={NSLocalizedDescription=Encryption is insufficient.}
	func bluetoothManager(_ manager: BGMBluetoothManager, peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
		if let error = error {
			let nsError = error as NSError
			if nsError.code == 15, nsError.domain == "CBATTErrorDomain" {
				DispatchQueue.main.async { [weak self] in
					self?.showFailure()
				}
			}
		} else {
			let device = CHDevice(peripheral: peripheral)
			UserDefaults.standard.bloodGlucoseMonitor = device
			bluetoothManager.stopMonitoring()
			DispatchQueue.main.async { [weak self] in
				self?.showSuccess()
			}
		}
	}

	func showSuccess() {
		viewModel.updateSuccess()
		NotificationCenter.default.post(name: .didPairBloodGlucoseMonitor, object: nil)
		continueButton.setTitle(NSLocalizedString("DONE", comment: "Done"), for: .normal)
		scrollToNextPage(animated: true)
	}

	func showFailure() {
		viewModel.updateFailure()
		continueButton.setTitle(NSLocalizedString("DONE", comment: "Done"), for: .normal)
		scrollToNextPage(animated: true)
	}
}
