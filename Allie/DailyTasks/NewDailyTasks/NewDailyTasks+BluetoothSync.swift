//
//  NewDailyTasks+BloodGlucoseMonitor.swift
//  Allie
//
//  Created by Onseen on 1/29/22.
//

import BluetoothService
import CareKitStore
import CodexFoundation
import CoreBluetooth
import HealthKit
import OmronKit
import UIKit

extension NewDailyTasksPageViewController: BluetoothServiceDelegate {
	var characteristics: [CBUUID: [CBUUID]] {
		[GATTServiceBloodGlucose.uuid: GATTServiceBloodGlucose.characteristics, GATTServiceBloodPressure.uuid: GATTServiceBloodPressure.characteristics,
		 GATTServiceBatteryService.uuid: GATTServiceBatteryService.characteristics, GATTServiceCurrentTime.uuid: GATTServiceCurrentTime.characteristics,
		 GATTServiceWeightScale.uuid: GATTServiceWeightScale.characteristics]
	}

	func bluetoothService(_ service: BluetoothService, didUpdate state: CBManagerState) {
		ALog.info("Bluetooth state = \(state.rawValue)")
		let state: Bool = state == .poweredOn ? true : false
		if state {
			ALog.info("Bluetooth Active")
			// let options: [String: Any] = [CBCentralManagerScanOptionAllowDuplicatesKey: true
			bluetoothService.scanForPeripherals()
			ALog.info("Starting BLE scan\n")
		} else {
			ALog.error("Bluetooth Start Error")
		}
	}

	func startBluetooth() {
		bluetoothService.addDelegate(self)
		bluetoothService.startMonitoring()
		startObservingManagerState()
	}

	func stopBluetooth() {
		bluetoothService.stopMonitoring()
	}

	func bluetoothService(_ service: BluetoothService, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
		guard let peripherals = careManager.patient?.peripherals, !peripherals.isEmpty else {
			return
		}

		if let currentDevice = careManager.patient?.bloodGlucoseMonitor, peripheral.name == currentDevice.id {
			let device = BloodGlucosePeripheral(peripheral: peripheral, advertisementData: AdvertisementData(advertisementData: advertisementData), rssi: RSSI)
			device.delegate = self
			device.dataSource = self
			bluetoothDevices[device.identifier] = device
			service.connect(peripheral: peripheral)
		}
	}

	func bluetoothService(_ service: BluetoothService, didConnect peripheral: CBPeripheral) {
		ALog.info("\(#function) \(peripheral)")
		guard let device = bluetoothDevices[peripheral.identifier] else {
			return
		}
		device.discoverServices()
	}

	func bluetoothService(_ service: BluetoothService, didFailToConnect peripheral: CBPeripheral, error: Error?) {
		bluetoothDevices.removeValue(forKey: peripheral.identifier)
		service.startMonitoring()
	}

	func bluetoothService(_ service: BluetoothService, didDisconnect peripheral: CBPeripheral, error: Error?) {
		bluetoothDevices.removeValue(forKey: peripheral.identifier)
		service.startMonitoring()
	}
}

extension NewDailyTasksPageViewController {
	func startObservingManagerState() {
		OHQDeviceManager.shared().delegate = self
		managerStateObserver = OHQDeviceManager.shared().observe(\.state, options: [.initial, .new]) { [weak self] manager, _ in
			ALog.info("New State \(manager.state.rawValue)")
			if manager.state == .poweredOn {
				self?.scanForDevices()
			}
		}
	}

	func stopObservingManagerState() {
		managerStateObserver?.invalidate()
		managerStateObserver = nil
	}

	func scanForDevices() {
		OHQDeviceManager.shared().scanForDevices(with: .any) { [weak self] deviceInfo in
			let identifier = deviceInfo.identifier
			self?.deviceInfoCache[identifier] = deviceInfo
			if let bpm = self?.careManager.patient?.bloodPresssureMonitor, let localId = bpm.localId, localId == identifier.uuidString {
				self?.startSession(identifer: identifier)
			} else if let ws = self?.careManager.patient?.weightScale, let localId = ws.localId, localId == identifier.uuidString {
				self?.startSession(identifer: identifier)
			}
		} completion: { [weak self] completionReason in
			switch completionReason {
			case .canceled:
				self?.stopScanCompletion?()
			case .busy:
				self?.stopScan {
					self?.deviceInfoCache.removeAll(keepingCapacity: true)
					self?.scanForDevices()
				}
			case .disconnected:
				self?.scanForDevices()
			default:
				break
			}
		}
	}

	func stopScan(completion: VoidCompletionHandler?) {
		stopScanCompletion = completion
		OHQDeviceManager.shared().stopScan()
	}

	func startSession(identifer: UUID) {
		let options: [OHQSessionOptionKey: Any] = [.readMeasurementRecordsKey: true, .connectionWaitTimeKey: NSNumber(value: 60)]
		sessionData = SessionData(identifier: identifer, options: options)

		OHQDeviceManager.shared().startSession(withDevice: identifer, usingDataObserver: { [weak self] dataType, data in
			self?.sessionData?.add(data, with: dataType)
		}, connectionObserver: { state in
			ALog.info("State \(state)")
		}, completion: { [weak self] completionReason in
			self?.sessionData?.completionReason = completionReason
			switch completionReason {
			case .canceled:
				break
			case .connectionTimedOut:
				break
			default:
				if self?.sessionData?.deviceCategory == .bloodPressureMonitor {
					self?.saveBloodPressureData()
				} else if self?.sessionData?.deviceCategory == .weightScale {
					self?.saveBodyMassData()
				}
			}
		}, options: options)
	}
}

extension NewDailyTasksPageViewController: PeripheralDelegate {
	func syncGlucometer(device: BloodGlucosePeripheral, characteristic: CBCharacteristic) {
		guard let identifier = device.name else {
			return
		}

		healthKitManager.fetchSequenceNumbers(deviceId: identifier) { [weak self] values in
			guard let strongSelf = self else {
				return
			}

			strongSelf.healthKitManager.sequenceNumbers.insert(values: values, forDevice: identifier)
			let maxSequenceNumber = strongSelf.healthKitManager.sequenceNumbers.max(forDevice: identifier)
			device.fetchRecords(startSequenceNumber: maxSequenceNumber)
		}
	}
}

extension NewDailyTasksPageViewController: BloodGlucosePeripheralDataSource {
	func peripheralStartSequenceNumber(_ peripheral: Peripheral) async -> Int? {
		guard let identifier = peripheral.name else {
			return nil
		}

		let values = await healthKitManager.fetchSequenceNumbers(deviceId: identifier)
		healthKitManager.sequenceNumbers.insert(values: values, forDevice: identifier)
		let maxSequenceNumber = healthKitManager.sequenceNumbers.max(forDevice: identifier)
		return maxSequenceNumber
	}

	func device(_ device: BloodGlucosePeripheral, didReceive readings: [Int: BloodGlucoseReading]) {
		ALog.info("didReceive readings \(readings)")
		Task { [weak self] in
			guard let strongSelf = self else {
				return
			}
			do {
				let samples = try await strongSelf.healthKitManager.save(readings: readings, peripheral: device)
				strongSelf.updatePatient(peripheral: device)
				_ = try await strongSelf.process(samples: samples, quantityIdentifier: .bloodGlucose)
			} catch {
				ALog.error("Error saving data to health kit \(error.localizedDescription)", error: error)
				DispatchQueue.main.async {
					let title = NSLocalizedString("ERROR", comment: "Error")
					strongSelf.showErrorAlert(title: title, message: error.localizedDescription)
				}
			}
		}
	}

	func updatePatient(peripheral: Peripheral) {
		guard var patient = careManager.patient, var pairedPeripheral = patient.peripheral(device: peripheral) else {
			return
		}
		patient.peripherals.remove(pairedPeripheral)
		let date = Date()
		let seconds = date.timeIntervalSince1970
		let millisecondsString = String(Int64(seconds * 1000))
		pairedPeripheral.lastSync = millisecondsString
		pairedPeripheral.lastSyncDate = date
		patient.peripherals.insert(pairedPeripheral)
		careManager.patient = patient
		careManager.upload(patient: patient)
	}

	func process(samples: [HKSample], quantityIdentifier: HKQuantityTypeIdentifier) async throws -> [OCKOutcome] {
		let uploadEndDate = UserDefaults.standard[healthKitOutcomesUploadDate: quantityIdentifier.rawValue]
		let samplesToUpload = samples.filter { sample in
			sample.startDate <= uploadEndDate
		}
		let outcomes = try await careManager.upload(samples: samplesToUpload, quantityIdentifier: quantityIdentifier)
		return try await careManager.save(outcomes: outcomes)
	}

	func process(samples: [HKSample], quantityIdentifier: HKQuantityTypeIdentifier) {
		let uploadEndDate = UserDefaults.standard[healthKitOutcomesUploadDate: quantityIdentifier.rawValue]
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

	func showBGMFoundAlert(device: Peripheral) {
		let title = NSLocalizedString("BGM_DETECTED", comment: "Glucose meter detected!")
		let message = NSLocalizedString("BGM_DETECTED.message", comment: "Would you like to connect to the following device:") + "\n\n" + (device.name ?? "Contour Diabetes Meter")
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Cancel"), style: .cancel) { [weak self] _ in
			// self?.bluetoothManager.discoveredPeripherals[device.identifier] = device
		}
		alertController.addAction(cancelAction)
		let connectAction = UIAlertAction(title: NSLocalizedString("CONNECT", comment: "Connect"), style: .default) { [weak self] _ in
			guard self?.careManager.patient?.peripheral(serviceType: GATTServiceBloodGlucose.identifier) == nil else {
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

extension NewDailyTasksPageViewController {
	func saveBloodPressureData() {
		guard let sessionData = sessionData, let records = sessionData.measurementRecords, !records.isEmpty else {
			ALog.error("unable to find records in session Data = \(String(describing: sessionData?.measurementRecords))")
			scanForDevices()
			return
		}

		let samples = records.compactMap { record in
			try? HKSample.createBloodPressure(sessionData: sessionData, record: record)
		}

		guard !samples.isEmpty else {
			self.sessionData = nil
			scanForDevices()
			return
		}
		healthKitManager.save(samples: samples) { [weak self] result in
			switch result {
			case .failure(let error):
				ALog.error("Unable to save samples", error: error)
			case .success(let samples):
				ALog.info("Number of samples saved = \(samples.count)")
			}
			self?.sessionData = nil
			self?.scanForDevices()
		}
	}
}

extension NewDailyTasksPageViewController {
	func saveBodyMassData() {
		guard let sessionData = sessionData, let records = sessionData.measurementRecords, !records.isEmpty else {
			ALog.error("unable to find records in session Data = \(String(describing: sessionData?.measurementRecords))")
			scanForDevices()
			return
		}

		let samples = records.compactMap { record in
			try? HKSample.createBodyMass(sessionData: sessionData, record: record)
		}

		guard !samples.isEmpty else {
			self.sessionData = nil
			scanForDevices()
			return
		}
		healthKitManager.save(samples: samples) { [weak self] result in
			switch result {
			case .failure(let error):
				ALog.error("Unable to save samples", error: error)
			case .success(let samples):
				ALog.info("Number of samples saved = \(samples.count)")
			}
			self?.sessionData = nil
			self?.scanForDevices()
		}
	}
}

extension NewDailyTasksPageViewController: PairingViewControllerDelegate {
	func pairingViewControllerDidFinish(_ controller: PairingViewController) {
		controller.dismiss(animated: true, completion: nil)
	}

	func pairingViewControllerDidCancel(_ controller: PairingViewController) {
		controller.dismiss(animated: true, completion: nil)
	}
}

extension NewDailyTasksPageViewController: OHQDeviceManagerDelegate {
	func deviceManager(_ manager: OHQDeviceManager, didFindDeviceWithInfo deviceInfo: [OHQDeviceInfoKey: Any]) {
		let identifier = deviceInfo.identifier
		deviceInfoCache[identifier] = deviceInfo
		if let bpm = careManager.patient?.bloodPresssureMonitor, let localId = bpm.localId, localId == identifier.uuidString {
			startSession(identifer: deviceInfo.identifier)
		} else if let ws = careManager.patient?.weightScale, let localId = ws.localId, localId == identifier.uuidString {
			startSession(identifer: identifier)
		}
	}
}
