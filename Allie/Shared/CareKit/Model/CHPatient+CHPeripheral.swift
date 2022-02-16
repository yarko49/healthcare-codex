//
//  CHPatient+CHPeripheral.swift
//  Allie
//
//  Created by Waqar Malik on 1/12/22.
//

import BluetoothService
import Foundation

extension CHPatient {
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
		peripherals.first { peripheral in
			peripheral.type == serviceType
		}
	}

	func peripheral(device: Peripheral) -> CHPeripheral? {
		peripherals.first { element in
			element.id == device.name
		}
	}

	var bloodGlucoseMonitor: CHPeripheral? {
		peripherals.first { peripheral in
			peripheral.type == GATTServiceBloodGlucose.identifier
		}
	}

	var bloodPresssureMonitor: CHPeripheral? {
		peripherals.first { peripheral in
			peripheral.type == GATTServiceBloodPressure.identifier
		}
	}

	var weightScale: CHPeripheral? {
		peripherals.first { peripheral in
			peripheral.type == GATTServiceWeightScale.identifier
		}
	}
}
