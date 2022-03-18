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
		OHQDeviceManager.shared().delegate = self
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

		OHQDeviceManager.shared().startSession(withDevice: identifer, usingDataObserver: { [weak self] dataType, data in
			ALog.info("Adding Data Type: \(dataType.rawValue), data: \(data)")
			self?.sessionData?.add(data, with: dataType)
		}, connectionObserver: { state in
			ALog.info("State \(state)")
		}, completion: { [weak self] completionReason in
			self?.sessionData?.completionReason = completionReason
			if let category = deviceInfo.category {
				switch category {
				case .bloodPressureMonitor:
					self?.saveBloodPressureData()
				case .weightScale, .bodyCompositionMonitor:
					self?.saveBodyMassData()
				default:
					break
				}
			}
		}, options: options)
	}

	func saveBloodPressureData(sessionData: SessionData?) async {
		do {
			guard let sessionData = sessionData, let records = sessionData.measurementRecords, !records.isEmpty else {
				throw AllieError.missing("unable to find records in session Data = \(String(describing: sessionData?.measurementRecords))")
			}

			var hkBloodPressureTask: OCKHealthKitTask?

			let chBloodPressureTask = careManager.tasks.values.first { task in
				guard let linkage = task.healthKitLinkage, linkage.quantityIdentifier == .bloodPressureSystolic || linkage.quantityIdentifier == .bloodPressureDiastolic else {
					return false
				}
				return true
			}

			if let bloodPressureTask = chBloodPressureTask {
				hkBloodPressureTask = try? await careManager.healthKitStore.fetchTask(withID: bloodPressureTask.id)
			}

			var hkRestingHeartRateTask: OCKHealthKitTask?
			let chRestingHeartRateTask = careManager.tasks.values.first(where: { task in
				guard let linkage = task.healthKitLinkage, linkage.quantityIdentifier == .restingHeartRate else {
					return false
				}
				return true
			})
			if let chRestingHeartRateTask = chRestingHeartRateTask {
				hkRestingHeartRateTask = try? await careManager.healthKitStore.fetchTask(withID: chRestingHeartRateTask.id)
			}

			var samples: [HKSample] = []
			var outcomes: [CHOutcome] = []
			records.forEach { record in
				if let sample = try? HKSample.createBloodPressure(sessionData: sessionData, record: record) {
					samples.append(sample)
					if let task = hkBloodPressureTask, let carePlanId = task.carePlanId ?? careManager.activeCarePlan?.id {
						let outcome = CHOutcome(sample: sample, task: task, carePlanId: carePlanId, deletedSample: nil)
						if let outcome = outcome {
							outcomes.append(outcome)
						}
					}
				}

				if let sample = try? HKSample.createRestingHeartRate(sessionData: sessionData, record: record) {
					samples.append(sample)
					if let task = hkRestingHeartRateTask, let carePlanId = task.carePlanId ?? careManager.activeCarePlan?.id {
						let outcome = CHOutcome(sample: sample, task: task, carePlanId: carePlanId, deletedSample: nil)
						if let outcome = outcome {
							outcomes.append(outcome)
						}
					}
				}

				if let outcome = CHOutcome(irregularRhythm: sessionData, record: record) {
					outcomes.append(outcome)
				}
			}

			if !samples.isEmpty {
				_ = try await healthKitManager.save(samples: samples)
			}
			_ = try await careManager.upload(outcomes: outcomes)
		} catch {
			ALog.error("Unable to save blood pressure data", error: error)
		}
		self.sessionData = nil
		scanForDevices()
	}

	func saveBloodPressureData() {
		Task { [weak self] in
			await self?.saveBloodPressureData(sessionData: self?.sessionData)
		}
	}

	func saveBodyMassData(sessionData: SessionData?) async {
		do {
			guard let sessionData = sessionData, let records = sessionData.measurementRecords, !records.isEmpty else {
				throw AllieError.missing("unable to find records in session Data = \(String(describing: sessionData?.measurementRecords))")
			}

			let samples = records.compactMap { record in
				try? HKSample.createBodyMass(sessionData: sessionData, record: record)
			}

			if !samples.isEmpty {
				_ = try await healthKitManager.save(samples: samples)
			}
		} catch {
			ALog.error("Unable to save body mass data", error: error)
		}
		self.sessionData = nil
		scanForDevices()
	}

	func saveBodyMassData() {
		Task { [weak self] in
			await self?.saveBodyMassData(sessionData: self?.sessionData)
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
}

extension BluetoothSyncManager: BloodGlucosePeripheralDataSource {
	func peripheralStartSequenceNumber(_ peripheral: Peripheral, completion: @escaping (Result<Int, Error>) -> Void) {
		guard let identifier = peripheral.name else {
			completion(.failure(AllieError.invalid("Invalid perpherial identifier")))
			return
		}

		healthKitManager.fetchSequenceNumbers(deviceId: identifier) { [weak self] values in
			guard let strongSelf = self else {
				completion(.failure(AllieError.invalid("Self was deallocated")))
				return
			}
			strongSelf.healthKitManager.sequenceNumbers.insert(values: values, forDevice: identifier)
			guard let maxSequenceNumber = strongSelf.healthKitManager.sequenceNumbers.max(forDevice: identifier) else {
				completion(.failure(AllieError.invalid("Sequence number was not found")))
				return
			}
			completion(.success(maxSequenceNumber))
		}
	}

	func device(_ device: BloodGlucosePeripheral, didReceive readings: [Int: BloodGlucoseReading]) {
		ALog.info("didReceive readings \(readings)")
		Task.detached(priority: .userInitiated) { [weak self] in
			if let samples = try? await self?.healthKitManager.save(readings: readings, peripheral: device), !samples.isEmpty {
				try await self?.updatePatient(peripheral: device)
				_ = try await self?.process(samples: samples, quantityIdentifier: .bloodGlucose)
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

extension BluetoothSyncManager: PeripheralDelegate {
	func peripheral(_ peripheral: Peripheral, didDiscoverServices services: [CBService], error: Error?) {
		ALog.info("\(#function) peripheral: \(peripheral) services: \(services)")
	}

	func peripheral(_ peripheral: Peripheral, readyWith characteristic: CBCharacteristic) {
		ALog.info("\(#function) peripheral: \(peripheral) characteristic: \(characteristic)")
	}

	func peripheral(_ peripheral: Peripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
		ALog.info("\(#function) peripheral: \(peripheral) characteristic: \(characteristic)")
	}

	func peripheral(_ peripheral: Peripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
		ALog.info("\(#function) peripheral: \(peripheral) characteristic: \(characteristic)")
	}
}
