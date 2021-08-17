//
//  BluetoothManager.swift
//  Allie
//
//  Created by Waqar Malik on 7/26/21.
//

import Combine
import CoreBluetooth
import Foundation

protocol BGMBluetoothManagerDelegate: AnyObject {
	func bluetoothManager(_ manager: BGMBluetoothManager, didActivate state: Bool)
	func bluetoothManager(_ manager: BGMBluetoothManager, didFindDevice device: CBPeripheral, rssi: Int)
	func bluetoothManager(_ manager: BGMBluetoothManager, deviceReadyWith racpCharacteristic: CBCharacteristic)
	func bluetoothManager(_ manager: BGMBluetoothManager, didReceive data: [BGMDataReading])
}

class BGMBluetoothManager: NSObject, ObservableObject {
	let glucoseServiceId = CBUUID(string: "0x1808")

	enum Command {
		static let allRecords: [UInt8] = [1, 1] // 1,1 get all records
		static let numberOfRecords: [UInt8] = [4, 1] // 4,1 get number of records
		// static let lastRecord: [UInt8] = [1, 6] // 1,6 get last record received
		// static let firstRecord: [UInt8] = [1, 5] // 1,5 get first record
		// static let recordStart: [UInt8] = [1, 3, 1, 45, 0] // 1,3,1,45,0 extract from record 45 onwards

		static func recordStart(sequenceNumber: Int) -> [UInt8] {
			let sequence = sequenceNumber + 1 // sequenceNumber is the last glucose record that was written to HK
			let seqLowByte = UInt8(0xFF & sequence)
			let seqHighByte = UInt8(sequence >> 8)
			ALog.info("Fetch data starting sequence #: \(sequenceNumber)")
			// [1, 3, 1, seqLowByte, seqHighByte]
			return [1, 3, 1, seqLowByte, seqHighByte]
		}
	}

	weak var delegate: BGMBluetoothManagerDelegate?
	private var centralManager: CBCentralManager!
	@Published var pairedPeripheral: CBPeripheral?
	@Published var peripherals: Set<CBPeripheral> = []
	var racpCharacteristic: CBCharacteristic? // BGM Record Access Control Point
	private var cancellables: Set<AnyCancellable> = []
	private var receivedDataSet: [BGMDataReading] = []
	private lazy var receivedData = BGMDataReading(measurement: [], context: [], peripheral: pairedPeripheral)
	private let supportedCharacteristics: Set<CBUUID> = BGMCharacteristic.supportedCharacteristics

	func startMonitoring() {
		centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
	}

	func scanForPeripherals() {
		centralManager.scanForPeripherals(withServices: [glucoseServiceId]) // if BLE is powered, kick off scan for BGMs
	}

	func connect(peripheral: CBPeripheral) {
		pairedPeripheral = peripheral
		pairedPeripheral?.delegate = self
		centralManager.stopScan()
		centralManager.connect(peripheral)
	}

	// Write 1 byte message to the BLE peripheral
	func writeMessage(peripheral: CBPeripheral, characteristic: CBCharacteristic, message: [UInt8]) {
		ALog.info("doWrite: \(message)")
		let data = Data(bytes: message, count: message.count)
		peripheral.writeValue(data, for: characteristic, type: .withResponse)
	}

	deinit {
		centralManager.stopScan()
		pairedPeripheral?.delegate = nil
		pairedPeripheral = nil
	}
}

extension BGMBluetoothManager: CBCentralManagerDelegate {
	func centralManagerDidUpdateState(_ central: CBCentralManager) {
		let state: Bool = central.state == .poweredOn ? true : false
		delegate?.bluetoothManager(self, didActivate: state)
	}

	func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
		ALog.info("didConnect: \(peripheral), services = \(String(describing: peripheral.services))")
		pairedPeripheral?.discoverServices([glucoseServiceId])
	}

	func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
		if error != nil {
			ALog.error("didDisconnectPeripheral \(peripheral), error \(error.debugDescription)")
		} else {
			ALog.info("didDisconnectPeripheral: \(peripheral)")
		}
		pairedPeripheral?.delegate = nil
		pairedPeripheral = nil
		scanForPeripherals()
	}

	func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
		pairedPeripheral?.delegate = nil
		pairedPeripheral = nil
	}

	func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
		ALog.info("didDiscover \(peripheral), advertisementData \(advertisementData), rssi: \(RSSI)")
		delegate?.bluetoothManager(self, didFindDevice: peripheral, rssi: RSSI.intValue)
	}
}

extension BGMBluetoothManager: CBPeripheralDelegate {
	func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
		ALog.info("didDiscoverServices")
		guard let services = peripheral.services else {
			return
		}

		services.forEach { service in
			peripheral.discoverCharacteristics(nil, for: service) // Now find the Characteristics of these Services
		}
	}

	func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
		ALog.info("didDiscoverCharacteristicsFor \(service)")
		guard let characteristics = service.characteristics else {
			return
		}

		// Set notifications for glucose measurement and context
		// 0x2a18 is glucose measurement, 0x2a34 is context, 0x2a52 is RACP
		for characteristic in characteristics {
			if supportedCharacteristics.contains(characteristic.uuid) {
				peripheral.setNotifyValue(true, for: characteristic)
			}

			if characteristic.uuid == BGMCharacteristic.racp.uuid {
				delegate?.bluetoothManager(self, deviceReadyWith: characteristic)
			}
		}
	}

	// For notified characteristics, here's the triggered method when a value comes in from the Peripheral
	func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
		ALog.info("didUpdateValueForCharacteristic \(characteristic)")
		if let value = characteristic.value {
			ALog.info("dataBuffer \(value)")
			// Turn input stream of UInt8 to an array of Ints so that can use standard methods in Model
			let valueArray = [UInt8](value)
			let outputArray = valueArray.map { byte in
				Int(byte)
			}

			switch characteristic.uuid {
			case BGMCharacteristic.measurement.uuid:
				// Glucose measurement value
				receivedData.measurement = outputArray
				receivedData.peripheral = peripheral
				if (outputArray[0] & 0b10000) == 0 { // No context attached, just do the write
					receivedDataSet.append(receivedData)
					receivedData = BGMDataReading(measurement: [], context: [], peripheral: peripheral)
				}
			case BGMCharacteristic.context.uuid:
				// Glucose context value
				receivedData.context = outputArray
				receivedDataSet.append(receivedData)
				receivedData = BGMDataReading(measurement: [], context: [], peripheral: peripheral) // reset the received tuple

			case BGMCharacteristic.racp.uuid:
				delegate?.bluetoothManager(self, didReceive: receivedDataSet)

			default:
				break
			}
		}
	}
}
