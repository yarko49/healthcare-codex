//
//  CHPatient+CHPeripheral.swift
//  Allie
//
//  Created by Waqar Malik on 1/12/22.
//

import BluetoothService
import CodexFoundation
import Foundation

public extension CHPatient {
	var bgmPeripheral: CHPeripheral? {
		guard let identifier = bgmIdentifier, let name = bgmName else {
			return nil
		}

		var peripheral = CHPeripheral(id: identifier, type: GATTServiceBloodGlucose.identifier, name: name)
		peripheral.address = bgmAddress
		peripheral.lastSync = bgmLastSync
		if let dateString = bgmLastSyncDate {
			let date = ISO8601DateFormatter.iso8601WithFractionalSeconds.date(from: dateString)
			peripheral.lastSyncDate = date
		}
		return peripheral
	}

	func exists(serviceType: String) -> Bool {
		peripheral(serviceType: serviceType) != nil
	}

	func peripheral(serviceType: String) -> CHPeripheral? {
		peripherals[serviceType]
	}

	func peripheral(device: Peripheral) -> CHPeripheral? {
		peripherals.first { (_: String, value: CHPeripheral) in
			value.name == device.name
		}?.value
	}

	var bloodGlucoseMonitor: CHPeripheral? {
		peripherals[GATTServiceBloodGlucose.identifier]
	}

	var bloodPresssureMonitor: CHPeripheral? {
		peripherals[GATTServiceBloodPressure.identifier]
	}

	var weightScale: CHPeripheral? {
		peripherals[GATTServiceWeightScale.identifier]
	}
}
