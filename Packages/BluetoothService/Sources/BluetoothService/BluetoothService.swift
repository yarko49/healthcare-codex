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
	func bluetoothService(_ service: BluetoothService, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber)
	func bluetoothService(_ service: BluetoothService, didConnect peripheral: CBPeripheral)
	func bluetoothService(_ service: BluetoothService, didFailToConnect peripheral: CBPeripheral, error: Error?)
	func bluetoothService(_ service: BluetoothService, didDisconnect peripheral: CBPeripheral, error: Error?)
}

public extension BluetoothServiceDelegate {
	func bluetoothService(_ service: BluetoothService, didUpdate state: CBManagerState) {}
	func bluetoothService(_ service: BluetoothService, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {}
	func bluetoothService(_ service: BluetoothService, didConnect peripheral: CBPeripheral) {}
	func bluetoothService(_ service: BluetoothService, didFailToConnect peripheral: CBPeripheral, error: Error?) {}
	func bluetoothService(_ service: BluetoothService, didDisconnect peripheral: CBPeripheral, error: Error?) {}
}

public class BluetoothService: NSObject, ObservableObject {
	// Object stored in the MulticastDelegate are weak objects, but we need the set to strong
	// swiftlint:disable:next weak_delegate
	private var multicastDelegate: MulticastDelegate<BluetoothServiceDelegate> = .init()
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

	public func startMonitoring() {
		let options: [String: Any] = [CBCentralManagerOptionShowPowerAlertKey: false]
		centralManager = CBCentralManager(delegate: self, queue: nil, options: options)
	}

	public func stopMonitoring() {
		centralManager?.stopScan()
	}

	public func scanForPeripherals(services: Set<CBUUID>, options: [String: Any] = [:]) {
		centralManager?.scanForPeripherals(withServices: Array(services), options: options) // if BLE is powered, kick off scan for BGMs
	}

	public func connect(peripheral: CBPeripheral, options: [String: Any]? = nil) {
		centralManager?.stopScan()
		centralManager?.connect(peripheral, options: options)
	}

	public func cancelConnection(_ peripheral: CBPeripheral) {
		centralManager?.cancelPeripheralConnection(peripheral)
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
		multicastDelegate.invoke { delegate in
			delegate?.bluetoothService(self, didConnect: peripheral)
		}
	}

	public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
		if error != nil {
			os_log(.error, log: .service, "didDisconnectPeripheral %@, error %@", peripheral, error.debugDescription)
		} else {
			os_log(.debug, log: .service, "didDisconnectPeripheral %@", peripheral)
		}

		multicastDelegate.invoke { delegate in
			delegate?.bluetoothService(self, didDisconnect: peripheral, error: error)
		}
	}

	public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
		os_log(.error, log: .service, "%@, error %@", peripheral, error.debugDescription)
		multicastDelegate.invoke { delegate in
			delegate?.bluetoothService(self, didFailToConnect: peripheral, error: error)
		}
	}

	public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
		os_log(.debug, log: .service, "didDiscover %@, advertisementData %@, rssi: %@", peripheral, advertisementData, RSSI)
		multicastDelegate.invoke { delegate in
			delegate?.bluetoothService(self, didDiscover: peripheral, advertisementData: advertisementData, rssi: RSSI)
		}
	}

	public func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral) {
		os_log(.debug, log: .service, "event: %d, peripheral: %@", event.rawValue, peripheral.name ?? peripheral.description)
	}

	public func centralManager(_ central: CBCentralManager, didUpdateANCSAuthorizationFor peripheral: CBPeripheral) {
		os_log(.debug, log: .service, "peripheral: %@", peripheral.name ?? peripheral.description)
	}
}
