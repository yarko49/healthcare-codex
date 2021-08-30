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
	func bluetoothManager(_ manager: BGMBluetoothManager, didUpdate state: CBManagerState)
	func bluetoothManager(_ manager: BGMBluetoothManager, didFindDevice peripheral: CBPeripheral, rssi: Int)
	func bluetoothManager(_ manager: BGMBluetoothManager, didConnect peripheral: CBPeripheral)
	func bluetoothManager(_ central: BGMBluetoothManager, didFailToConnect peripheral: CBPeripheral, error: Error?)
	func bluetoothManager(_ manager: BGMBluetoothManager, peripheral: CBPeripheral, readyWith characteristic: CBCharacteristic)
	func bluetoothManager(_ manager: BGMBluetoothManager, didReceive data: [BGMDataReading])
	func bluetoothManager(_ manager: BGMBluetoothManager, peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?)
}

extension BGMBluetoothManagerDelegate {
	func bluetoothManager(_ manager: BGMBluetoothManager, didUpdate state: CBManagerState) {}
	func bluetoothManager(_ manager: BGMBluetoothManager, didFindDevice peripheral: CBPeripheral, rssi: Int) {}
	func bluetoothManager(_ manager: BGMBluetoothManager, didConnect peripheral: CBPeripheral) {}
	func bluetoothManager(_ central: BGMBluetoothManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {}
	func bluetoothManager(_ manager: BGMBluetoothManager, peripheral: CBPeripheral, readyWith characteristic: CBCharacteristic) {}
	func bluetoothManager(_ manager: BGMBluetoothManager, didReceive data: [BGMDataReading]) {}
	func bluetoothManager(_ manager: BGMBluetoothManager, peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {}
}

class BGMBluetoothManager: NSObject, ObservableObject {
	weak var delegate: BGMBluetoothManagerDelegate?
	private var centralManager: CBCentralManager!

	var services: Set<CBUUID> = [GATTService.bloodGlucose.uuid, GATTService.deviceInformation.uuid]
	var deviceCharacteristics: Set<CBUUID> = Set([GATTCharacteristic.firmwareRevisionString, .hardwareRevisionsString, .softwareRevisionString, .serialNumberString, .manufacturerNameString, .manufacturerModelNumberString, .timeZone, .systemId].map(\.uuid))
	var measurementCharacteristics: Set<CBUUID> = Set([GATTCharacteristic.bloodGlucoseMeasurement, .bloodGlucoseMeasurementContext, .recordAccessControlPoint].map(\.uuid))
	@Published var pairedPeripheral: CBPeripheral?
	@Published var peripherals: Set<CBPeripheral> = []
	var racpCharacteristic: CBCharacteristic? // BGM Record Access Control Point
	private var cancellables: Set<AnyCancellable> = []
	private var receivedDataSet: [BGMDataReading] = []
	private lazy var receivedData = BGMDataReading(measurement: [], context: [], peripheral: pairedPeripheral)
	var device = CHDevice()

	func peripheral(for identifier: String) -> CBPeripheral? {
		peripherals.first { peripheral in
			peripheral.identifier.uuidString == identifier
		}
	}

	func isConntect(identifier: String) -> Bool {
		guard let device = pairedPeripheral else {
			return false
		}

		return device.identifier.uuidString == identifier
	}

	func startMonitoring() {
		centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
	}

	func stopMonitoring() {
		centralManager.stopScan()
		pairedPeripheral?.delegate = nil
		pairedPeripheral = nil
	}

	func scanForPeripherals() {
		centralManager.scanForPeripherals(withServices: Array(services)) // if BLE is powered, kick off scan for BGMs
	}

	func connect(peripheral: CBPeripheral) {
		pairedPeripheral = peripheral
		pairedPeripheral?.delegate = self
		centralManager.stopScan()
		centralManager.connect(peripheral, options: nil)
	}

	// Write 1 byte message to the BLE peripheral
	func writeMessage(peripheral: CBPeripheral, characteristic: CBCharacteristic, message: [UInt8]) {
		ALog.info("doWrite: \(message)")
		let data = Data(bytes: message, count: message.count)
		peripheral.writeValue(data, for: characteristic, type: .withResponse)
	}

	deinit {
		stopMonitoring()
	}
}

extension BGMBluetoothManager: CBCentralManagerDelegate {
	func centralManagerDidUpdateState(_ central: CBCentralManager) {
		delegate?.bluetoothManager(self, didUpdate: central.state)
	}

	func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
		ALog.info("didConnect: \(peripheral), services = \(String(describing: peripheral.services))")
		pairedPeripheral?.discoverServices(Array(services))
		delegate?.bluetoothManager(self, didConnect: peripheral)
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
		delegate?.bluetoothManager(self, didFailToConnect: peripheral, error: error)
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

		let supportedCharacteristics = deviceCharacteristics.union(measurementCharacteristics)
		// Set notifications for glucose measurement and context
		// 0x2a18 is glucose measurement, 0x2a34 is context, 0x2a52 is RACP
		for characteristic in characteristics {
			if supportedCharacteristics.contains(characteristic.uuid) {
				peripheral.setNotifyValue(true, for: characteristic)
			}

			if characteristic.uuid == GATTCharacteristic.recordAccessControlPoint.uuid {
				delegate?.bluetoothManager(self, peripheral: peripheral, readyWith: characteristic)
			}
		}
	}

	func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
		delegate?.bluetoothManager(self, peripheral: peripheral, didWriteValueFor: characteristic, error: error)
	}

	// For notified characteristics, here's the triggered method when a value comes in from the Peripheral
	func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
		ALog.info("didUpdateValueForCharacteristic \(characteristic)")
		if measurementCharacteristics.contains(characteristic.uuid) {
			processMeasurement(characteristic: characteristic, for: peripheral)
		} else if deviceCharacteristics.contains(characteristic.uuid) {
			processDevice(characteristic: characteristic, for: peripheral)
		}
	}

	private func processMeasurement(characteristic: CBCharacteristic, for peripheral: CBPeripheral) {
		guard let value = characteristic.value else {
			return
		}
		ALog.info("dataBuffer \(value)")
		// Turn input stream of UInt8 to an array of Ints so that can use standard methods in Model
		let valueArray = [UInt8](value)
		let outputArray = valueArray.map { byte in
			Int(byte)
		}

		switch characteristic.uuid {
		case GATTCharacteristic.bloodGlucoseMeasurement.uuid:
			// Glucose measurement value
			receivedData.measurement = outputArray
			receivedData.peripheral = peripheral
			receivedData.measurementData = value

			if (outputArray[0] & 0b10000) == 0 { // No context attached, just do the write
				receivedDataSet.append(receivedData)
				receivedData = BGMDataReading(measurement: [], context: [], peripheral: peripheral)
			}
		case GATTCharacteristic.bloodGlucoseMeasurementContext.uuid:
			// Glucose context value
			receivedData.context = outputArray
			receivedData.contextData = value
			receivedDataSet.append(receivedData)
			receivedData = BGMDataReading(measurement: [], context: [], peripheral: peripheral) // reset the received tuple

		case GATTCharacteristic.recordAccessControlPoint.uuid:
			delegate?.bluetoothManager(self, didReceive: receivedDataSet)

		default:
			break
		}
	}

	private func processDevice(characteristic: CBCharacteristic, for peripheral: CBPeripheral) {
		guard let value = characteristic.value else {
			return
		}
		let valueString = String(data: value, encoding: .utf8)

		switch characteristic.uuid {
		case GATTCharacteristic.hardwareRevisionsString.uuid:
			ALog.info("Hardware Revision \(valueString ?? "No hardware revision")")
			device.hardwareVersion = valueString
		case GATTCharacteristic.firmwareRevisionString.uuid:
			ALog.info("Firmware Revision \(valueString ?? "No firmware revision")")
			device.firmwareVersion = valueString
		case GATTCharacteristic.softwareRevisionString.uuid:
			ALog.info("Software Revision \(valueString ?? "No software revision")")
			device.softwareVersion = valueString
		case GATTCharacteristic.serialNumberString.uuid:
			ALog.info("Serial Number \(valueString ?? "No serial number")")
		case GATTCharacteristic.manufacturerNameString.uuid:
			ALog.info("Name \(valueString ?? "No Name")")
			device.name = valueString
		case GATTCharacteristic.manufacturerModelNumberString.uuid:
			ALog.info("Model Number \(valueString ?? "No Model Number")")
			device.model = valueString
		case GATTCharacteristic.timeZone.uuid:
			ALog.info("Timezone \(valueString ?? "No Timezone")")
		case GATTCharacteristic.systemId.uuid:
			ALog.info("SystemId \(valueString ?? "No System Id")")
			device.localIdentifier = valueString
		default:
			break
		}
	}
}
