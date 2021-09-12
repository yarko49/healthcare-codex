//
//  DailyTasks+BloodGlucoseMonitor.swift
//  Allie
//
//  Created by Waqar Malik on 8/12/21.
//

import CoreBluetooth
import HealthKit
import UIKit

extension DailyTasksPageViewController: BGMBluetoothManagerDelegate {
	func startBluetooth() {
		bloodGlucoseMonitor.multicastDelegate.add(self)
		bloodGlucoseMonitor.startMonitoring()
	}

	func bluetoothManager(_ manager: BGMBluetoothManager, didUpdate state: CBManagerState) {
		ALog.info("Bluetooth state = \(state)")
		let state: Bool = state == .poweredOn ? true : false
		if state {
			ALog.info("Bluetooth Active")
			bloodGlucoseMonitor.scanForPeripherals()
			ALog.info("Starting BLE scan\n")
		} else {
			ALog.error("Bluetooth Start Error")
		}
	}

	func bluetoothManager(_ manager: BGMBluetoothManager, didFind peripheral: CBPeripheral, rssi: Int) {
		if let currentDevice = UserDefaults.standard.bloodGlucoseMonitor, peripheral.identifier == currentDevice.uuid {
			bloodGlucoseMonitor.connect(peripheral: peripheral)
			return
		}

		guard !manager.peripherals.contains(peripheral) else {
			return
		}
		manager.peripherals.insert(peripheral)
	}

	func bluetoothManager(_ manager: BGMBluetoothManager, peripheral: CBPeripheral, readyWith characteristic: CBCharacteristic) {
		manager.racpCharacteristic = characteristic
		if let glucometer = manager.pairedPeripheral, let racp = manager.racpCharacteristic, let identifier = glucometer.name {
			healthKitManager.findSequenceNumber(deviceId: identifier)
				.sink { [weak self] sequenceNumber in
					var command = GATTCommand.allRecords
					if sequenceNumber > 0 {
						command = GATTCommand.recordStart(sequenceNumber: sequenceNumber)
					}
					self?.bloodGlucoseMonitor.writeMessage(peripheral: glucometer, characteristic: racp, message: command, isBatched: true)
				}.store(in: &cancellables)
		}
	}

	func bluetoothManager(_ manager: BGMBluetoothManager, peripheral: CBPeripheral, didReceive readings: [BGMDataReading]) {
		ALog.info("didReceive readings \(readings)")
		healthKitManager.save(readings: readings, peripheral: peripheral)
			.sinkOnMain { [weak self] completionResult in
				if case .failure(let error) = completionResult {
					ALog.error("Error saving data to health kit \(error.localizedDescription)", error: error)
					let title = NSLocalizedString("ERROR", comment: "Error")
					self?.showErrorAlert(title: title, message: error.localizedDescription)
				}
			} receiveValue: { [weak self] samples in
				self?.process(samples: samples, quantityIdentifier: .bloodGlucose)
			}.store(in: &cancellables)
	}

	func process(samples: [HKSample], quantityIdentifier: HKQuantityTypeIdentifier) {
		let uploadEndDate = UserDefaults.standard[lastOutcomesUploadDate: quantityIdentifier.rawValue]
		let samplesToUpload = samples.filter { sample in
			sample.startDate <= uploadEndDate
		}

		careManager.upload(samples: samplesToUpload, quantityIdentifier: quantityIdentifier)
			.sinkOnMain { completionResult in
				if case .failure(let error) = completionResult {
					ALog.error("Error uploading outcomes", error: error)
				}
			} receiveValue: { [weak self] outcomes in
				guard let strongSelf = self else {
					return
				}
				strongSelf.careManager.save(outcomes: outcomes)
					.sinkOnMain { completionResult in
						if case .failure(let error) = completionResult {
							ALog.error("Error saving outcomes", error: error)
						}
					} receiveValue: { _ in
						ALog.info("Saved outcomes")
					}.store(in: &strongSelf.cancellables)
			}.store(in: &cancellables)
	}

	func showBGMFoundAlert(device: CBPeripheral) {
		let title = NSLocalizedString("BGM_DETECTED", comment: "Glucose meter detected!")
		let message = NSLocalizedString("BGM_DETECTED.message", comment: "Would you like to connect to the following device:") + "\n\n" + (device.name ?? "Contour Diabetes Meter")
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Cancel"), style: .cancel) { [weak self] _ in
			self?.bloodGlucoseMonitor.peripherals.insert(device)
		}
		alertController.addAction(cancelAction)
		let connectAction = UIAlertAction(title: NSLocalizedString("CONNECT", comment: "Connect"), style: .default) { [weak self] _ in
			guard UserDefaults.standard.bloodGlucoseMonitor == nil else {
				self?.showCannotPair()
				return
			}
			self?.showConnectFlow(identifier: device.identifier.uuidString)
		}
		alertController.addAction(connectAction)
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

	func showErrorAlert(title: String, message: String?) {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Ok"), style: .default) { _ in
		}
		alertController.addAction(okAction)
		(tabBarController ?? navigationController ?? self).showDetailViewController(alertController, sender: self)
	}

	func showConnectFlow(identifier: String) {
		let viewController = BGMPairingViewController()
		viewController.modalPresentationStyle = .fullScreen
		viewController.delegate = self
		viewController.selectedIdentifier = identifier
		(tabBarController ?? navigationController ?? self).showDetailViewController(viewController, sender: self)
	}
}

extension DailyTasksPageViewController: BGMPairingViewControllerDelegate {
	func pairingViewControllerDidFinish(_ controller: BGMPairingViewController) {
		controller.dismiss(animated: true, completion: nil)
	}

	func pairingViewControllerDidCancel(_ controller: BGMPairingViewController) {
		controller.dismiss(animated: true, completion: nil)
	}
}
