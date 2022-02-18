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
	func peripheral(_ peripheral: Peripheral, didDiscoverServices services: [CBService], error: Error?)
	func peripheral(_ peripheral: Peripheral, readyWith characteristic: CBCharacteristic)
	func peripheral(_ peripheral: Peripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?)
	func peripheral(_ peripheral: Peripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?)
}

public extension PeripheralDelegate {
	func peripheral(_ peripheral: Peripheral, didDiscoverServices services: [CBService], error: Error?) {}
	func peripheral(_ peripheral: Peripheral, readyWith characteristic: CBCharacteristic) {}
	func peripheral(_ peripheral: Peripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {}
	func peripheral(_ peripheral: Peripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {}
}

open class Peripheral: NSObject, ObservableObject {
	public let peripheral: CBPeripheral
	public let advertisementData: AdvertisementData
	public let rssi: NSNumber
	public internal(set) var supportedServices: Set<CBUUID> = []
	public internal(set) var supportedCharacteristics: [CBUUID: [CBUUID]] = [:]
	public internal(set) var measurementCharacteristics: Set<CBUUID> = []
	public internal(set) var discoveredCharacteristics: [CBUUID: CBCharacteristic] = [:]

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

	open func discoverServices(_ services: [CBUUID]? = nil) {
		peripheral.discoverServices(services ?? Array(supportedServices))
	}

	open func discover(characteristics: [CBUUID]?, for service: CBService) {
		peripheral.discoverCharacteristics(characteristics, for: service)
	}

	open func discoverDescriptors(for characteristic: CBCharacteristic) {
		peripheral.discoverDescriptors(for: characteristic)
	}

	open func writeMessage(characteristic: CBCharacteristic, message: [UInt8], isBatched: Bool) {
		os_log(.info, log: .peripheral, "%@ %@", #function, message)
		let data = Data(bytes: message, count: message.count)
		write(value: data, for: characteristic)
	}

	open func write(message: [UInt8], for characteristic: CBCharacteristic, type: CBCharacteristicWriteType = .withResponse) {
		os_log(.info, log: .peripheral, "%@ %@", #function, message)
		let data = Data(bytes: message, count: message.count)
		write(value: data, for: characteristic, type: .withResponse)
	}

	open func write(value: Data, for characteristic: CBCharacteristic, type: CBCharacteristicWriteType = .withResponse) {
		os_log(.info, log: .peripheral, "%@ %@", #function, value.asciiEncodedString ?? "")
		peripheral.writeValue(value, for: characteristic, type: type)
	}

	open func write(message: [UInt8], for descriptor: CBDescriptor) {
		os_log(.info, log: .peripheral, "%@ %@", #function, message)
		let data = Data(bytes: message, count: message.count)
		write(value: data, for: descriptor)
	}

	open func write(value: Data, for descriptor: CBDescriptor) {
		os_log(.info, log: .peripheral, "%@ %@", #function, value.asciiEncodedString ?? "")
		peripheral.writeValue(value, for: descriptor)
	}

	open func setNotify(enabled: Bool, for characteristic: CBCharacteristic) {
		peripheral.setNotifyValue(enabled, for: characteristic)
	}

	open func read(characteristic: CBCharacteristic, isBatched: Bool) {
		peripheral.readValue(for: characteristic)
	}

	open func reset() {
		discoveredCharacteristics.removeAll(keepingCapacity: true)
	}

	open func processMeasurement(characteristic: CBCharacteristic, for peripheral: CBPeripheral) {
		os_log(.info, log: .peripheral, "%@ CBPeripheral %@, CBCharacteristic %@", #function, peripheral.displayName, characteristic.uuid)
	}
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
	// Service
	open func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
		let services = peripheral.services ?? []
		if let error = error {
			os_log(.error, log: .peripheral, "%@, error: %@", #function, error.localizedDescription)
		} else {
			os_log(.info, log: .peripheral, "%@", #function)
			services.forEach { service in
				let characteristics = supportedCharacteristics[service.uuid]
				peripheral.discoverCharacteristics(characteristics, for: service)
			}
		}
		delegate?.peripheral(self, didDiscoverServices: services, error: error)
	}

	// Characteristics
	open func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
		if let error = error {
			os_log(.error, log: .peripheral, "%@, service: %@ error: %@", #function, service, error.localizedDescription)
			return
		}

		os_log(.info, log: .peripheral, "%@: service = %@", #function, service)
		guard let characteristics = service.characteristics else {
			return
		}

		for characteristic in characteristics {
			setNotify(enabled: true, for: characteristic)

			os_log(.info, log: .peripheral, "%@: characteristic = %@", #function, characteristic)
			discoveredCharacteristics[characteristic.uuid] = characteristic
			delegate?.peripheral(self, readyWith: characteristic)
			discoverDescriptors(for: characteristic)
		}
	}

	open func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
		os_log(.info, log: .peripheral, "%@ %@ %@", #function, characteristic.uuid, error?.localizedDescription ?? "")
		delegate?.peripheral(self, didWriteValueFor: characteristic, error: error)
	}

	// For notified characteristics, here's the triggered method when a value comes in from the Peripheral
	open func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
		os_log(.info, log: .peripheral, "%@ %@ $%@$ %@", #function, characteristic.uuid, characteristic.value?.base64EncodedString() ?? "", error?.localizedDescription ?? "")
		delegate?.peripheral(self, didUpdateValueFor: characteristic, error: error)
		if measurementCharacteristics.contains(characteristic.uuid) {
			processMeasurement(characteristic: characteristic, for: peripheral)
		}
	}

	open func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
		os_log(.info, log: .peripheral, "%@ %@ %@ %@", #function, peripheral.displayName, characteristic, error?.localizedDescription ?? "")
	}

	// Descriptors
	open func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
		os_log(.info, log: .peripheral, "%@ %@ %@ %@", #function, peripheral.displayName, characteristic, error?.localizedDescription ?? "")
	}

	open func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
		os_log(.info, log: .peripheral, "%@ %@ %@ %@", #function, peripheral.displayName, descriptor, error?.localizedDescription ?? "")
	}

	open func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
		os_log(.info, log: .peripheral, "%@ %@ %@ %@", #function, peripheral.displayName, descriptor, error?.localizedDescription ?? "")
	}
}
