//
//  File.swift
//
//
//  Created by Waqar Malik on 12/8/21.
//

import BluetoothService
import Combine
import CoreBluetooth
import Foundation
import os.log

private extension OSLog {
	static let device = {
		#if DEBUG
		OSLog(subsystem: Bundle(for: AKDevice.self).bundleIdentifier!, category: "AKDeviceManager")
		#else
		OSLog.disabled
		#endif
	}()
}

public protocol AKDeviceDataSource {
	func device(_ device: AKDevice, didReceive readings: [Int: AKBloodGlucoseReading])
}

public extension AKDeviceDataSource {
	func device(_ device: AKDevice, didReceive readings: [Int: AKBloodGlucoseReading]) {}
}

public class AKDevice: Peripheral {
	public var dataSource: AKDeviceDataSource?
	public var racpCharacteristic: CBCharacteristic? // BGM Record Access Control Point
	private var batchReadings: [Int: AKBloodGlucoseReading] = [:]
	private var currentReading: AKBloodGlucoseReading
	public private(set) var isBatchProcessing: Bool = false

	override public init(peripheral: CBPeripheral, advertisementData: AdvertisementData, rssi: NSNumber) {
		self.currentReading = AKBloodGlucoseReading(measurement: [], context: [], peripheral: peripheral)
		super.init(peripheral: peripheral, advertisementData: advertisementData, rssi: rssi)
	}

	public convenience init(peripheral: Peripheral) {
		self.init(peripheral: peripheral.peripheral, advertisementData: peripheral.advertisementData, rssi: peripheral.rssi)
	}

	override public func writeMessage(characteristic: CBCharacteristic, message: [UInt8], isBatched: Bool) {
		isBatchProcessing = isBatched
		super.writeMessage(characteristic: characteristic, message: message, isBatched: isBatched)
	}

	public func fetchRecords(startSequenceNumber: Int? = nil) {
		guard let racpCharacteristic = racpCharacteristic else {
			return
		}

		var command = GATTRACPCommands.allRecords
		if let startSequenceNumber = startSequenceNumber, startSequenceNumber > 0 {
			command = GATTRACPCommands.recordStart(sequenceNumber: startSequenceNumber)
		}
		writeMessage(characteristic: racpCharacteristic, message: command, isBatched: true)
	}

	public func fetchNumberOfRecords() {
		guard let racpCharacteristic = racpCharacteristic else {
			return
		}
		writeMessage(characteristic: racpCharacteristic, message: GATTRACPCommands.numberOfRecords, isBatched: true)
	}

	override public func reset() {
		super.reset()
		racpCharacteristic = nil
		isBatchProcessing = false
		batchReadings.removeAll()
		currentReading = AKBloodGlucoseReading(measurement: [], context: [], peripheral: peripheral)
	}

	override public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
		if let error = error {
			os_log(.error, log: .device, "%@, service: %@ error: %@", #function, service, error.localizedDescription)
			return
		}

		os_log(.info, log: .device, "%@ %@", #function, service)
		guard let characteristics = service.characteristics else {
			return
		}

		// Set notifications for glucose measurement and context
		// 0x2a18 is glucose measurement, 0x2a34 is context, 0x2a52 is RACP
		for characteristic in characteristics {
			if measurementCharacteristics.contains(characteristic.uuid) {
				peripheral.setNotifyValue(true, for: characteristic)
			}

			delegate?.peripheral(self, readyWith: characteristic)
			if characteristic.uuid == GATTDeviceCharacteristic.recordAccessControlPoint.uuid {
				racpCharacteristic = characteristic
			}
		}
	}

	override public func processMeasurement(characteristic: CBCharacteristic, for peripheral: CBPeripheral) {
		guard let value = characteristic.value else {
			return
		}
		os_log(.info, log: .device, "%@ process measurement data Value $%@$", #function, String(data: value, encoding: .ascii)!)
		// Turn input stream of UInt8 to an array of Ints so that can use standard methods in Model
		let valueArray = [UInt8](value)
		let outputArray = valueArray.map { byte in
			Int(byte)
		}
		switch characteristic.uuid {
		case GATTDeviceCharacteristic.bloodGlucoseMeasurement.uuid:
			// Glucose measurement value
			currentReading.measurement = outputArray
			currentReading.peripheral = peripheral
			currentReading.measurementData = value

			if (outputArray[0] & 0b10000) == 0 { // No context attached, just do the write
				if isBatchProcessing {
					batchReadings[currentReading.sequence] = currentReading
				} else {
					dataSource?.device(self, didReceive: [currentReading.sequence: currentReading])
				}
				currentReading = AKBloodGlucoseReading(measurement: [], context: [], peripheral: peripheral)
			}

		case GATTDeviceCharacteristic.bloodGlucoseMeasurementContext.uuid:
			// Glucose context value
			currentReading.context = outputArray
			currentReading.contextData = value
			if isBatchProcessing {
				batchReadings[currentReading.sequence] = currentReading
			} else {
				dataSource?.device(self, didReceive: [currentReading.sequence: currentReading])
			}
			currentReading = AKBloodGlucoseReading(measurement: [], context: [], peripheral: peripheral) // reset the received tuple

		case GATTDeviceCharacteristic.recordAccessControlPoint.uuid:
			isBatchProcessing = false
			guard !batchReadings.isEmpty else {
				return
			}
			dataSource?.device(self, didReceive: batchReadings)
			batchReadings.removeAll()

		default:
			os_log(.info, log: .device, "%@ Unknown characteristic uuid received %@", #function, characteristic.uuid)
		}
	}
}
