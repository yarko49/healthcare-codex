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
	func bluetoothManager(_ manager: BGMBluetoothManager, didFind peripheral: CBPeripheral, rssi: Int)
	func bluetoothManager(_ manager: BGMBluetoothManager, didConnect peripheral: CBPeripheral)
	func bluetoothManager(_ central: BGMBluetoothManager, didFailToConnect peripheral: CBPeripheral, error: Error?)
	func bluetoothManager(_ manager: BGMBluetoothManager, peripheral: CBPeripheral, readyWith characteristic: CBCharacteristic)
	func bluetoothManager(_ manager: BGMBluetoothManager, peripheral: CBPeripheral, didReceive readings: [BGMDataReading])
	func bluetoothManager(_ manager: BGMBluetoothManager, peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?)
}

extension BGMBluetoothManagerDelegate {
	func bluetoothManager(_ manager: BGMBluetoothManager, didUpdate state: CBManagerState) {}
	func bluetoothManager(_ manager: BGMBluetoothManager, didFind peripheral: CBPeripheral, rssi: Int) {}
	func bluetoothManager(_ manager: BGMBluetoothManager, didConnect peripheral: CBPeripheral) {}
	func bluetoothManager(_ central: BGMBluetoothManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {}
	func bluetoothManager(_ manager: BGMBluetoothManager, peripheral: CBPeripheral, readyWith characteristic: CBCharacteristic) {}
	func bluetoothManager(_ manager: BGMBluetoothManager, peripheral: CBPeripheral, didReceive readings: [BGMDataReading]) {}
	func bluetoothManager(_ manager: BGMBluetoothManager, peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {}
}

class BGMBluetoothManager: NSObject, ObservableObject {
	// Object stored in the MulticastDelegate are weak objects, but we need the set to strong
	// swiftlint:disable:next weak_delegate
	var multicastDelegate: MulticastDelegate<BGMBluetoothManagerDelegate> = .init()

	var services: Set<CBUUID> = [GATTService.bloodGlucose.uuid, GATTService.deviceInformation.uuid]
	var deviceCharacteristics: Set<CBUUID> = Set(GATTCharacteristic.deviceInfo.map(\.uuid))
	var measurementCharacteristics: Set<CBUUID> = Set(GATTCharacteristic.bloodGlucoseMeasurements.map(\.uuid))
	@Published var pairedPeripheral: CBPeripheral?
	@Published var peripherals: Set<CBPeripheral> = []
	@Published var racpCharacteristic: CBCharacteristic? // BGM Record Access Control Point
	var device = CHDevice.contourNextOne

	private var centralManager: CBCentralManager?
	private var cancellables: Set<AnyCancellable> = []
	private var batchReadings: [BGMDataReading] = []
	private var isBatchProcessingEnabled: Bool = false
	private lazy var currentReading = BGMDataReading(measurement: [], context: [], peripheral: pairedPeripheral)

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
		centralManager?.stopScan()
		pairedPeripheral?.delegate = nil
		pairedPeripheral = nil
	}

	func scanForPeripherals() {
		centralManager?.scanForPeripherals(withServices: Array(services)) // if BLE is powered, kick off scan for BGMs
	}

	func connect(peripheral: CBPeripheral) {
		pairedPeripheral = peripheral
		pairedPeripheral?.delegate = self
		centralManager?.stopScan()
		centralManager?.connect(peripheral, options: nil)
	}

	// Write 1 byte message to the BLE peripheral
	func writeMessage(peripheral: CBPeripheral, characteristic: CBCharacteristic, message: [UInt8], isBatched: Bool) {
		ALog.info("doWrite: \(message)")
		isBatchProcessingEnabled = isBatched
		let data = Data(bytes: message, count: message.count)
		peripheral.writeValue(data, for: characteristic, type: .withResponse)
	}

	deinit {
		stopMonitoring()
	}
}

extension BGMBluetoothManager: CBCentralManagerDelegate {
	func centralManagerDidUpdateState(_ central: CBCentralManager) {
		multicastDelegate.invoke { delegate in
			delegate?.bluetoothManager(self, didUpdate: central.state)
		}
	}

	func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
		ALog.info("didConnect: \(peripheral), services = \(String(describing: peripheral.services))")
		pairedPeripheral?.discoverServices(Array(services))
		multicastDelegate.invoke { delegate in
			delegate?.bluetoothManager(self, didConnect: peripheral)
		}
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
		multicastDelegate.invoke { delegate in
			delegate?.bluetoothManager(self, didFailToConnect: peripheral, error: error)
		}
	}

	func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
		ALog.info("didDiscover \(peripheral), advertisementData \(advertisementData), rssi: \(RSSI)")
		multicastDelegate.invoke { delegate in
			delegate?.bluetoothManager(self, didFind: peripheral, rssi: RSSI.intValue)
		}
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
				multicastDelegate.invoke { delegate in
					delegate?.bluetoothManager(self, peripheral: peripheral, readyWith: characteristic)
				}
			}
		}
	}

	func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
		multicastDelegate.invoke { delegate in
			delegate?.bluetoothManager(self, peripheral: peripheral, didWriteValueFor: characteristic, error: error)
		}
	}

	// For notified characteristics, here's the triggered method when a value comes in from the Peripheral
	func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
		ALog.trace("didUpdateValueForCharacteristic \(characteristic.uuid)")
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
		ALog.info("process measurement data Value \(value)")
		// Turn input stream of UInt8 to an array of Ints so that can use standard methods in Model
		let valueArray = [UInt8](value)
		let outputArray = valueArray.map { byte in
			Int(byte)
		}

		switch characteristic.uuid {
		case GATTCharacteristic.bloodGlucoseMeasurement.uuid:
			// Glucose measurement value
			currentReading.measurement = outputArray
			currentReading.peripheral = peripheral
			currentReading.measurementData = value

			if (outputArray[0] & 0b10000) == 0 { // No context attached, just do the write
				if isBatchProcessingEnabled {
					batchReadings.append(currentReading)
				} else {
					multicastDelegate.invoke { delegate in
						delegate?.bluetoothManager(self, peripheral: peripheral, didReceive: [currentReading])
					}
				}
				currentReading = BGMDataReading(measurement: [], context: [], peripheral: peripheral)
			}

		case GATTCharacteristic.bloodGlucoseMeasurementContext.uuid:
			// Glucose context value
			currentReading.context = outputArray
			currentReading.contextData = value
			if isBatchProcessingEnabled {
				batchReadings.append(currentReading)
			} else {
				multicastDelegate.invoke { delegate in
					delegate?.bluetoothManager(self, peripheral: peripheral, didReceive: [currentReading])
				}
			}
			currentReading = BGMDataReading(measurement: [], context: [], peripheral: peripheral) // reset the received tuple

		case GATTCharacteristic.recordAccessControlPoint.uuid:
			guard !batchReadings.isEmpty else {
				return
			}
			multicastDelegate.invoke { delegate in
				delegate?.bluetoothManager(self, peripheral: peripheral, didReceive: batchReadings)
			}
			batchReadings.removeAll()
			isBatchProcessingEnabled = false

		default:
			ALog.info("Unknown characteristic uuid received = \(characteristic.uuid)")
		}
	}

	private func processDevice(characteristic: CBCharacteristic, for peripheral: CBPeripheral) {
		guard let value = characteristic.value else {
			return
		}
		ALog.info("process device info data Value \(value)")
		let valueString = String(data: value, encoding: .utf8)

		switch characteristic.uuid {
		case GATTCharacteristic.hardwareRevisions.uuid:
			ALog.info("Hardware Revision \(valueString ?? "No hardware revision")")
			device.hardwareVersion = valueString
		case GATTCharacteristic.firmwareRevision.uuid:
			ALog.info("Firmware Revision \(valueString ?? "No firmware revision")")
			device.firmwareVersion = valueString
		case GATTCharacteristic.softwareRevision.uuid:
			ALog.info("Software Revision \(valueString ?? "No software revision")")
			device.softwareVersion = valueString
		case GATTCharacteristic.manufacturerSerialNumber.uuid:
			ALog.info("Serial Number \(valueString ?? "No serial number")")
		case GATTCharacteristic.manufacturerName.uuid:
			ALog.info("Name \(valueString ?? "No Name")")
			device.name = valueString
		case GATTCharacteristic.manufacturerModelNumber.uuid:
			ALog.info("Model Number \(valueString ?? "No Model Number")")
			device.model = valueString
		case GATTCharacteristic.timeZone.uuid:
			ALog.info("Timezone \(valueString ?? "No Timezone")")
		case GATTCharacteristic.manufacturerSystemId.uuid:
			ALog.info("SystemId \(valueString ?? "No System Id")")
			device.localIdentifier = valueString
		default:
			break
		}
	}
}
