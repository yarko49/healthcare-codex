//
//  BluetoothService.swift
//
//  Created by Waqar Malik on 12/10/21.
//

import Combine
import CoreBluetooth
import Foundation
import os.log

private extension OSLog {
	static let service = {
		#if DEBUG
		OSLog(subsystem: "com.codexhealth.BluetoothService", category: "BluetoothService")
		#else
		OSLog.disabled
		#endif
	}()
}

public protocol BluetoothServiceDelegate: AnyObject {
	func bluetoothService(_ service: BluetoothService, didUpdate state: CBManagerState)
	func bluetoothService(_ service: BluetoothService, didDiscover peripheral: Peripheral)
	func bluetoothService(_ service: BluetoothService, didConnect peripheral: Peripheral)
	func bluetoothService(_ service: BluetoothService, didFailToConnect peripheral: Peripheral, error: Error?)
	func bluetoothService(_ service: BluetoothService, didDisconnect peripheral: Peripheral, error: Error?)
}

public extension BluetoothServiceDelegate {
	func bluetoothService(_ service: BluetoothService, didUpdate state: CBManagerState) {}
	func bluetoothService(_ service: BluetoothService, didDiscover peripheral: Peripheral) {}
	func bluetoothService(_ service: BluetoothService, didConnect peripheral: Peripheral) {}
	func bluetoothService(_ service: BluetoothService, didFailToConnect peripheral: Peripheral, error: Error?) {}
	func bluetoothService(_ service: BluetoothService, didDisconnect peripheral: Peripheral, error: Error?) {}
}

public class BluetoothService: NSObject, ObservableObject {
	// Object stored in the MulticastDelegate are weak objects, but we need the set to strong
	// swiftlint:disable:next weak_delegate
	private var multicastDelegate: MulticastDelegate<BluetoothServiceDelegate> = .init()

	@Published public private(set) var discoveredPeripherals: [UUID: Peripheral] = [:]
	public private(set) var centralManager: CBCentralManager?

	public var isScanning: Bool {
		centralManager?.isScanning ?? false
	}

	public func addDelegate(_ delegate: BluetoothServiceDelegate) {
		multicastDelegate.add(delegate)
	}

	public func removeDelegate(_ delegate: BluetoothServiceDelegate) {
		multicastDelegate.remove(delegate)
	}

	public func peripheral(uuidString: String) -> Peripheral? {
		guard let uuid = UUID(uuidString: uuidString) else {
			return nil
		}

		return peripheral(uuid: uuid)
	}

	public func peripheral(uuid: UUID) -> Peripheral? {
		discoveredPeripherals[uuid]
	}

	public func isConnected(uuidString: String) -> Bool {
		guard let uuid = UUID(uuidString: uuidString) else {
			return false
		}

		return isConnected(uuid: uuid)
	}

	public func isConnected(uuid: UUID) -> Bool {
		discoveredPeripherals[uuid] != nil
	}

	public func startMonitoring() {
		let options: [String: Any] = [CBCentralManagerOptionShowPowerAlertKey: false]
		centralManager = CBCentralManager(delegate: self, queue: nil, options: options)
	}

	public func stopMonitoring() {
		centralManager?.stopScan()
	}

	public func scanForPeripherals(services: Set<CBUUID>, options: [String: Any] = [:]) {
		discoveredPeripherals.removeAll(keepingCapacity: true)
		centralManager?.scanForPeripherals(withServices: Array(services), options: options) // if BLE is powered, kick off scan for BGMs
	}

	public func connect(peripheral: Peripheral, options: [String: Any]? = nil) {
		centralManager?.stopScan()
		centralManager?.connect(peripheral.peripheral, options: options)
	}

	public func cancelConnection(_ peripheral: Peripheral) {
		centralManager?.cancelPeripheralConnection(peripheral.peripheral)
	}

	public func peripherals(withIdentifiers identifiers: [UUID]) -> [CBPeripheral] {
		centralManager?.retrievePeripherals(withIdentifiers: identifiers) ?? []
	}

	public func connectedPeripherals(withServices serviceUUIDs: [CBUUID]) -> [CBPeripheral] {
		centralManager?.retrieveConnectedPeripherals(withServices: serviceUUIDs) ?? []
	}

	deinit {
		stopMonitoring()
	}
}

extension BluetoothService: CBCentralManagerDelegate {
	public func centralManagerDidUpdateState(_ central: CBCentralManager) {
		os_log(.debug, log: .service, "%@, state = %d", central, String(describing: central.state.rawValue))
		multicastDelegate.invoke { delegate in
			delegate?.bluetoothService(self, didUpdate: central.state)
		}
	}

	public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
		os_log(.debug, log: .service, "%@, services = %@", peripheral, String(describing: peripheral.services))
		guard let discovered = discoveredPeripherals[peripheral.identifier] else {
			return
		}
		multicastDelegate.invoke { delegate in
			delegate?.bluetoothService(self, didConnect: discovered)
		}
	}

	public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
		if error != nil {
			os_log(.error, log: .service, "didDisconnectPeripheral %@, error %@", peripheral, error.debugDescription)
		} else {
			os_log(.debug, log: .service, "didDisconnectPeripheral %@", peripheral)
		}

		guard let discovered = discoveredPeripherals[peripheral.identifier] else {
			return
		}
		multicastDelegate.invoke { delegate in
			delegate?.bluetoothService(self, didDisconnect: discovered, error: error)
		}

		discoveredPeripherals.removeValue(forKey: peripheral.identifier)
	}

	public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
		os_log(.error, log: .service, "%@, error %@", peripheral, error.debugDescription)
		guard let discovered = discoveredPeripherals[peripheral.identifier] else {
			return
		}
		multicastDelegate.invoke { delegate in
			delegate?.bluetoothService(self, didFailToConnect: discovered, error: error)
		}
	}

	public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
		os_log(.debug, log: .service, "didDiscover %@, advertisementData %@, rssi: %@", peripheral, advertisementData, RSSI)
		let discovered = Peripheral(peripheral: peripheral, advertisementData: AdvertisementData(advertisementData: advertisementData), rssi: RSSI)
		discoveredPeripherals[peripheral.identifier] = discovered
		multicastDelegate.invoke { delegate in
			delegate?.bluetoothService(self, didDiscover: discovered)
		}
	}

	public func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral) {
		os_log(.debug, log: .service, "event: %d, peripheral: %@", event.rawValue, peripheral.name ?? peripheral.description)
	}

	public func centralManager(_ central: CBCentralManager, didUpdateANCSAuthorizationFor peripheral: CBPeripheral) {
		os_log(.debug, log: .service, "peripheral: %@", peripheral.name ?? peripheral.description)
	}
}
