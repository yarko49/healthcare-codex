//
//  BluetoothSyncManager.swift
//  Allie
//
//  Created by Waqar Malik on 3/6/22.
//

import BluetoothService
import CareKitStore
import CareModel
import CodexFoundation
import CoreBluetooth
import Foundation
import HealthKit
import OmronKit

private struct BluetoothSyncManagerKey: InjectionKey {
	static var currentValue = BluetoothSyncManager()
}

extension InjectedValues {
	var syncManager: BluetoothSyncManager {
		get { Self[BluetoothSyncManagerKey.self] }
		set { Self[BluetoothSyncManagerKey.self] = newValue }
	}
}

class BluetoothSyncManager: NSObject, ObservableObject {
	@Injected(\.careManager) var careManager: CareManager
	@Injected(\.healthKitManager) var healthKitManager: HealthKitManager
	@Injected(\.networkAPI) var networkAPI: AllieAPI

	var bluetoothDevices: [UUID: Peripheral] = [:]
	var deviceInfoCache: [UUID: [OHQDeviceInfoKey: Any]] = [:]
	var stopScanCompletion: VoidCompletionHandler?
	var managerStateObserver: NSKeyValueObservation?
	var userData: [OHQUserDataKey: Any] = [:]
	var sessionData: SessionData?

	func start() {
		OHQDeviceManager.shared().add(delegate: self)
		managerStateObserver = OHQDeviceManager.shared().observe(\.state, options: [.initial, .new]) { [weak self] manager, _ in
			ALog.info("New State \(manager.state.rawValue)")
			if manager.state == .poweredOn {
				self?.scanForDevices()
			}
		}
	}

	func stop() {
		managerStateObserver?.invalidate()
		managerStateObserver = nil
	}

	func scanForDevices() {
		OHQDeviceManager.shared().scanForDevices(with: .any) { [weak self] deviceInfo in
			ALog.info("Device Did get device Info \(deviceInfo.modelName)")
			self?.startSessionIfNeeded(deviceInfo: deviceInfo)
		} completion: { completionReason in
			ALog.info("Device Did Complete = \(completionReason)")
		}
	}

	func stopScan(completion: VoidCompletionHandler?) {
		stopScanCompletion = completion
		OHQDeviceManager.shared().stopScan()
	}

	func startSession(identifer: UUID, deviceInfo: [OHQDeviceInfoKey: Any]) {
		let options: [OHQSessionOptionKey: Any] = [.readMeasurementRecordsKey: true, .connectionWaitTimeKey: NSNumber(value: 60)]
		sessionData = SessionData(identifier: identifer, options: options)

		OHQDeviceManager.shared().stopScan()
		OHQDeviceManager.shared().startSession(withDevice: identifer, usingDataObserver: { [weak self] dataType, data in
			ALog.info("Adding Data Type: \(dataType.rawValue), data: \(data)")
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
				guard let category = deviceInfo.category else {
					return
				}
				switch category {
				case .bloodPressureMonitor:
					self?.saveBloodPressureData()
				case .weightScale, .bodyCompositionMonitor:
					self?.saveBodyMassData()
				case .bloodGlucoseMonitor:
					break
				case .any, .unknown:
					break
				@unknown default:
					break
				}
			}
		}, options: options)
	}

	func saveBloodPressureData() {
		guard let sessionData = sessionData, let records = sessionData.measurementRecords, !records.isEmpty else {
			ALog.error("unable to find records in session Data = \(String(describing: sessionData?.measurementRecords))")
			scanForDevices()
			return
		}

		var samples: [HKSample] = []
		var outcomes: [CHOutcome] = []
		records.forEach { record in
			if let sample = try? HKSample.createBloodPressure(sessionData: sessionData, record: record) {
				samples.append(sample)
			}
			if let sample = try? HKSample.createRestingHeartRate(sessionData: sessionData, record: record) {
				samples.append(sample)
			}

			if let outcome = CHOutcome(irregularRhythm: sessionData, record: record) {
				outcomes.append(outcome)
			}
		}

		if !samples.isEmpty {
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

		careManager.upload(outcomes: outcomes) { result in
			if case .failure(let error) = result {
				ALog.error("Unable to upload outcomes", error: error)
			}
		}

		self.sessionData = nil
		scanForDevices()
	}

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

	func updatePatient(peripheral: Peripheral) async throws {
		guard var patient = careManager.patient, var pairedPeripheral = patient.peripheral(device: peripheral) else {
			return
		}
		patient.peripherals.removeValue(forKey: pairedPeripheral.type)
		let date = Date()
		let seconds = date.timeIntervalSince1970
		let millisecondsString = String(Int64(seconds * 1000))
		pairedPeripheral.lastSync = millisecondsString
		pairedPeripheral.lastSyncDate = date
		patient.peripherals[pairedPeripheral.type] = pairedPeripheral
		careManager.patient = patient
		_ = try await networkAPI.post(patient: patient)
	}

	func startSessionIfNeeded(deviceInfo: [OHQDeviceInfoKey: Any]) {
		let identifier = deviceInfo.identifier
		guard deviceInfoCache[identifier] == nil else {
			return
		}
		deviceInfoCache[identifier] = deviceInfo
		if let bpm = careManager.patient?.bloodPresssureMonitor, let localId = bpm.localId, localId == identifier.uuidString {
			startSession(identifer: deviceInfo.identifier, deviceInfo: deviceInfo)
		} else if let ws = careManager.patient?.weightScale, let localId = ws.localId, localId == identifier.uuidString {
			startSession(identifer: identifier, deviceInfo: deviceInfo)
		}
	}
}

extension BluetoothSyncManager: PeripheralDelegate {
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

extension BluetoothSyncManager: OHQDeviceManagerDelegate {
	func deviceManager(_ manager: OHQDeviceManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
		guard let peripherals = careManager.patient?.peripherals, !peripherals.isEmpty else {
			return
		}

		if let currentDevice = careManager.patient?.bloodGlucoseMonitor, peripheral.name == currentDevice.name || peripheral.name == currentDevice.id {
			guard bluetoothDevices[peripheral.identifier] == nil else {
				return
			}
			let device = BloodGlucosePeripheral(peripheral: peripheral, advertisementData: AdvertisementData(advertisementData: advertisementData), rssi: RSSI)
			device.delegate = self
			device.dataSource = self
			bluetoothDevices[device.identifier] = device
			manager.connectPerpherial(peripheral, withOptions: nil)
			manager.stopScan()
		} else if let deviceInfo = manager.deviceInfo(for: peripheral) {
			startSessionIfNeeded(deviceInfo: deviceInfo)
		}
	}

	func deviceManager(_ manager: OHQDeviceManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
		ALog.info("\(#function)")
		bluetoothDevices.removeValue(forKey: peripheral.identifier)
		deviceInfoCache.removeValue(forKey: peripheral.identifier)
	}

	func deviceManager(_ manager: OHQDeviceManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
		ALog.info("\(#function)")
		bluetoothDevices.removeValue(forKey: peripheral.identifier)
		deviceInfoCache.removeValue(forKey: peripheral.identifier)
	}

	func deviceManager(_ manager: OHQDeviceManager, didConnect peripheral: CBPeripheral) {
		ALog.info("\(#function)")
		guard let device = bluetoothDevices[peripheral.identifier] else {
			return
		}
		device.discoverServices()
	}

	func deviceManager(_ manager: OHQDeviceManager, shouldStartTransferForPeripherial peripheral: CBPeripheral) -> Bool {
		true
	}
}

extension BluetoothSyncManager: BloodGlucosePeripheralDataSource {
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
		Task.detached(priority: .userInitiated) { [weak self] in
			guard let strongSelf = self else {
				return
			}
			do {
				let samples = try await strongSelf.healthKitManager.save(readings: readings, peripheral: device)
				if !samples.isEmpty {
					try await strongSelf.updatePatient(peripheral: device)
					_ = try await strongSelf.process(samples: samples, quantityIdentifier: .bloodGlucose)
				}
			} catch {
				ALog.error("Error saving data to health kit \(error.localizedDescription)", error: error)
				// DispatchQueue.main.async {
				//   let title = NSLocalizedString("ERROR", comment: "Error")
				//   strongSelf.showErrorAlert(title: title, message: error.localizedDescription)
				// }
			}
		}
	}

	func process(samples: [HKSample], quantityIdentifier: HKQuantityTypeIdentifier) async throws -> [OCKOutcome] {
		let uploadEndDate = UserDefaults.standard[healthKitOutcomesUploadDate: quantityIdentifier.rawValue]
		let samplesToUpload = samples.filter { sample in
			sample.startDate <= uploadEndDate
		}
		let outcomes = try await careManager.upload(samples: samplesToUpload, quantityIdentifier: quantityIdentifier)
		return try await careManager.save(outcomes: outcomes)
	}
}
