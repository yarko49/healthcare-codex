//
//  Peripheral.swift
//
//
//  Created by Waqar Malik on 12/10/21.
//

import CoreBluetooth
import Foundation
import os.log

private extension OSLog {
	static let peripheral = {
		#if DEBUG
		OSLog(subsystem: Bundle(for: Peripheral.self).bundleIdentifier!, category: "BluetoothService")
		#else
		OSLog.disabled
		#endif
	}()
}

public protocol PeripheralDelegate: AnyObject {
	func peripheral(_ peripheral: Peripheral, readyWith characteristic: CBCharacteristic)
	func peripheral(_ peripheral: Peripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?)
}

public extension PeripheralDelegate {
	func peripheral(_ device: Peripheral, readyWith characteristic: CBCharacteristic) {}
	func peripheral(_ device: Peripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {}
}

open class Peripheral: NSObject, ObservableObject {
	public let peripheral: CBPeripheral
	public let advertisementData: AdvertisementData
	public let rssi: NSNumber
	public private(set) var notifyCharacteristics: Set<CBUUID> = []
	public private(set) var measurementCharacteristics: Set<CBUUID> = []
	open weak var delegate: PeripheralDelegate?

	@available(*, unavailable)
	override public init() {
		fatalError("init() has not been implemented")
	}

	public init(peripheral: CBPeripheral, advertisementData: AdvertisementData, rssi: NSNumber) {
		self.peripheral = peripheral
		self.advertisementData = advertisementData
		self.rssi = rssi
		super.init()
		peripheral.delegate = self
	}

	public var name: String? {
		peripheral.name
	}

	public var identifier: UUID {
		peripheral.identifier
	}

	public var services: [CBService] {
		peripheral.services ?? []
	}

	public var state: CBPeripheralState {
		peripheral.state
	}

	public var isConnected: Bool {
		state == .connected
	}

	public func discover(services: Set<CBUUID>, measurementCharacteristics: Set<CBUUID>, notifyCharacteristics: Set<CBUUID>) {
		self.measurementCharacteristics.formUnion(measurementCharacteristics)
		self.notifyCharacteristics.formUnion(notifyCharacteristics)
		peripheral.discoverServices(Array(services))
	}

	// Write 1 byte message to the BLE peripheral
	open func writeMessage(characteristic: CBCharacteristic, message: [UInt8], isBatched: Bool) {
		os_log(.info, log: .peripheral, "%@ %@", #function, message)
		let data = Data(bytes: message, count: message.count)
		peripheral.writeValue(data, for: characteristic, type: .withResponse)
	}

	open func reset() {}

	open func processMeasurement(characteristic: CBCharacteristic, for peripheral: CBPeripheral) {}
}

extension Peripheral {
	var allServices: [CBService] {
		var all: [CBService] = []
		for service in services {
			all.append(service)
			if let included = service.includedServices {
				all.append(contentsOf: included)
			}
		}
		return all
	}

	func service(uuid: CBUUID) -> CBService? {
		allServices.first { service in
			service.uuid == uuid
		}
	}
}

extension Peripheral: CBPeripheralDelegate {
	open func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
		if let error = error {
			os_log(.error, log: .peripheral, "%@, error: %@", #function, error.localizedDescription)
		} else {
			os_log(.info, log: .peripheral, "%@", #function)
		}
		guard let services = peripheral.services else {
			return
		}
		services.forEach { service in
			peripheral.discoverCharacteristics(Array(measurementCharacteristics), for: service) // Now find the Characteristics of these Services
		}
	}

	open func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
		if let error = error {
			os_log(.error, log: .peripheral, "%@, service: %@ error: %@", #function, service, error.localizedDescription)
			return
		}

		os_log(.info, log: .peripheral, "%@ %@", #function, service)
		guard let characteristics = service.characteristics else {
			return
		}

		for characteristic in characteristics {
			if measurementCharacteristics.contains(characteristic.uuid) {
				peripheral.setNotifyValue(true, for: characteristic)
			}

			if notifyCharacteristics.contains(characteristic.uuid) {
				delegate?.peripheral(self, readyWith: characteristic)
			}
		}
	}

	open func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
		os_log(.info, log: .peripheral, "%@ %@", #function, characteristic.uuid)
		delegate?.peripheral(self, didWriteValueFor: characteristic, error: error)
	}

	// For notified characteristics, here's the triggered method when a value comes in from the Peripheral
	open func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
		os_log(.info, log: .peripheral, "%@ %@", #function, characteristic.uuid)
		if measurementCharacteristics.contains(characteristic.uuid) {
			processMeasurement(characteristic: characteristic, for: peripheral)
		}
	}
}
