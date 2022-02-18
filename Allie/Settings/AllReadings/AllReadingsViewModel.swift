//
//  AllReadingsViewModel.swift
//  Allie
//
//  Created by Waqar Malik on 9/8/21.
//

import BluetoothService
import CodexFoundation
import Combine
import CoreBluetooth
import Foundation

class AllReadingsViewModel: ObservableObject {
	@Injected(\.bluetoothService) var bluetoothService: BluetoothService
	@Injected(\.careManager) var careManager: CareManager
	@Published var records: [BloodGlucoseRecord] = []
	private var cancellables: Set<AnyCancellable> = []
	var bluetoothDevices: [UUID: BloodGlucosePeripheral] = [:]

	init() {
		bluetoothService.removeDelegate(self)
		bluetoothService.startMonitoring()
	}

	func getAllData() {
		bluetoothDevices.forEach { (_: UUID, value: BloodGlucosePeripheral) in
			value.fetchRecords()
		}
	}
}

extension AllReadingsViewModel: BluetoothServiceDelegate {
	func bluetoothService(_ service: BluetoothService, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
		if let currentDevice = careManager.patient?.bloodGlucoseMonitor, peripheral.name == currentDevice.id {
			let device = BloodGlucosePeripheral(peripheral: peripheral, advertisementData: AdvertisementData(advertisementData: advertisementData), rssi: RSSI)
			device.delegate = self
			device.dataSource = self
			bluetoothDevices[device.identifier] = device
			bluetoothService.connect(peripheral: peripheral)
			return
		}
	}

	func bluetoothService(_ service: BluetoothService, didConnect peripheral: CBPeripheral) {
		ALog.info("\(#function) \(peripheral)")
		guard let peripherial = bluetoothDevices[peripheral.identifier] else {
			return
		}
		peripherial.discoverServices()
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

extension AllReadingsViewModel: PeripheralDelegate {
	func peripheral(_ peripheral: Peripheral, readyWith characteristic: CBCharacteristic) {
		if let glucometer = bluetoothDevices[peripheral.identifier] {
			glucometer.racpCharacteristic = characteristic
			glucometer.fetchRecords()
		}
	}
}

extension AllReadingsViewModel: BloodGlucosePeripheralDataSource {
	func device(_ device: BloodGlucosePeripheral, didReceive readings: [Int: BloodGlucoseReading]) {
		ALog.info("didReceive readings \(readings)")
		let records = readings.mapValues { reading in
			BloodGlucoseRecord(reading: reading)
		}
		DispatchQueue.main.async {
			self.records = Array(records.values)
		}
	}
}
