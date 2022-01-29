//
//  AllReadingsViewModel.swift
//  Allie
//
//  Created by Waqar Malik on 9/8/21.
//

import AscensiaKit
import BluetoothService
import CodexFoundation
import Combine
import CoreBluetooth
import Foundation

class AllReadingsViewModel: ObservableObject {
	@Injected(\.bluetoothService) var bluetoothService: BluetoothService
	@Injected(\.careManager) var careManager: CareManager
	@Published var records: [AKBloodGlucoseRecord] = []
	private var cancellables: Set<AnyCancellable> = []
	var bluetoothDevices: [UUID: AKDevice] = [:]

	init() {
		bluetoothService.removeDelegate(self)
		bluetoothService.startMonitoring()
	}

	func getAllData() {
		bluetoothDevices.forEach { (_: UUID, value: AKDevice) in
			value.fetchRecords()
		}
	}
}

extension AllReadingsViewModel: BluetoothServiceDelegate {
	func bluetoothService(_ service: BluetoothService, didDiscover peripheral: Peripheral) {
		if let currentDevice = careManager.patient?.bloodGlucoseMonitor, peripheral.name == currentDevice.id {
			let device = AKDevice(peripheral: peripheral)
			device.delegate = self
			device.dataSource = self
			bluetoothDevices[device.identifier] = device
			bluetoothService.connect(peripheral: peripheral)
			return
		}
	}

	func bluetoothService(_ service: BluetoothService, didConnect peripheral: Peripheral) {
		ALog.info("\(#function) \(peripheral.peripheral)")
		guard let deviceManager = bluetoothDevices[peripheral.identifier] else {
			return
		}
		let services = Set([GATTDeviceService.bloodGlucose.uuid])
		let characteristics = Set(GATTDeviceCharacteristic.bloodGlucoseMeasurements.map(\.uuid))
		deviceManager.discover(services: services, measurementCharacteristics: characteristics, notifyCharacteristics: [GATTDeviceCharacteristic.recordAccessControlPoint.uuid])
	}

	func bluetoothService(_ service: BluetoothService, didFailToConnect peripheral: Peripheral, error: Error?) {
		bluetoothDevices.removeValue(forKey: peripheral.identifier)
		service.startMonitoring()
	}

	func bluetoothService(_ service: BluetoothService, didDisconnect peripheral: Peripheral, error: Error?) {
		bluetoothDevices.removeValue(forKey: peripheral.identifier)
		service.startMonitoring()
	}
}

extension AllReadingsViewModel: PeripheralDelegate {
	func peripheral(_ peripheral: Peripheral, readyWith characteristic: CBCharacteristic) {
		if let glucometer = bluetoothDevices[peripheral.identifier] {
			glucometer.racpCharacteristic = characteristic
			glucometer.fetchRecords()
		}
	}
}

extension AllReadingsViewModel: AKDeviceDataSource {
	func device(_ device: AKDevice, didReceive readings: [Int: AKBloodGlucoseReading]) {
		ALog.info("didReceive readings \(readings)")
		let records = readings.mapValues { reading in
			AKBloodGlucoseRecord(reading: reading)
		}
		DispatchQueue.main.async {
			self.records = Array(records.values)
		}
	}
}
