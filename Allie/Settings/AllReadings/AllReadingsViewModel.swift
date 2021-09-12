//
//  AllReadingsViewModel.swift
//  Allie
//
//  Created by Waqar Malik on 9/8/21.
//

import Combine
import CoreBluetooth
import Foundation

class AllReadingsViewModel: ObservableObject {
	@Injected(\.bluetoothManager) var bluetoothManager: BGMBluetoothManager
	@Published var records: [BGMDataRecord] = []
	private var cancellables: Set<AnyCancellable> = []

	init() {
		bluetoothManager.multicastDelegate.add(self)
		bluetoothManager.$pairedPeripheral.sink { [weak self] peripheral in
			if let peripheral = peripheral {
				self?.readAllReadings(peripheral: peripheral)
			}
		}.store(in: &cancellables)
	}

	func readAllReadings(peripheral: CBPeripheral) {
		if let racp = bluetoothManager.racpCharacteristic {
			bluetoothManager.writeMessage(peripheral: peripheral, characteristic: racp, message: GATTCommand.allRecords, isBatched: true)
		}
	}

	func getAllData() {
		if let peripheral = bluetoothManager.pairedPeripheral {
			readAllReadings(peripheral: peripheral)
		}
	}
}

extension AllReadingsViewModel: BGMBluetoothManagerDelegate {
	func bluetoothManager(_ manager: BGMBluetoothManager, peripheral: CBPeripheral, didReceive reading: [BGMDataReading]) {
		let records = reading.map { reading in
			BGMDataRecord(reading: reading)
		}
		DispatchQueue.main.async {
			self.records = records
		}
	}
}
