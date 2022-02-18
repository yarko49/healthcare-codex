//
//  BloodPressurePeripheral.swift
//
//
//  Created by Waqar Malik on 2/9/22.
//

import Combine
import CoreBluetooth
import Foundation
import os.log

private extension OSLog {
	static let bpm = {
		#if DEBUG
		OSLog(subsystem: Bundle(for: BloodPressurePeripheral.self).bundleIdentifier!, category: "BloodPressurePeripheral")
		#else
		OSLog.disabled
		#endif
	}()
}

public class BloodPressurePeripheral: Peripheral {
	override public init(peripheral: CBPeripheral, advertisementData: AdvertisementData, rssi: NSNumber) {
		super.init(peripheral: peripheral, advertisementData: advertisementData, rssi: rssi)
		supportedCharacteristics = [GATTServiceBloodPressure.uuid: GATTServiceBloodPressure.characteristics,
		                            GATTServiceBatteryService.uuid: GATTServiceBatteryService.characteristics,
		                            GATTServiceCurrentTime.uuid: GATTServiceCurrentTime.characteristics]
		measurementCharacteristics = Set(GATTServiceBloodPressure.characteristics)
		supportedServices = [GATTServiceCurrentTime.uuid, GATTServiceBatteryService.uuid, GATTServiceBloodPressure.uuid]
	}

	var disoveredDescriptors: Set<CBUUID> = []

	override open func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
		os_log(.info, log: .bpm, "%@ %@ %@ %@", #function, peripheral.displayName, characteristic, error?.localizedDescription ?? "")
		disoveredDescriptors.insert(characteristic.uuid)
		if disoveredDescriptors.count == 3 {
			if let timeCharcteristic = discoveredCharacteristics[GATTBatteryLevel.uuid], let descriptor = timeCharcteristic.descriptors?.first {
				write(message: BluetoothService.EnableNotificationValue, for: descriptor)
			}
		}
	}

	override open func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
		os_log(.info, log: .bpm, "%@ %@ %@ %@", #function, peripheral.displayName, descriptor, error?.localizedDescription ?? "")
		guard let value = descriptor.value as? Data else {
			return
		}

		os_log(.info, log: .bpm, "%@ $%@$", #function, value.asciiEncodedString ?? "")
	}

	override open func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
		os_log(.info, log: .bpm, "%@ %@ %@ %@", #function, peripheral.displayName, descriptor, error?.localizedDescription ?? "")
		guard let characteristic = descriptor.characteristic else {
			return
		}

		if characteristic.uuid == GATTCurrentTime.uuid, let batteryLevel = discoveredCharacteristics[GATTBatteryLevel.uuid], let descriptor = batteryLevel.descriptors?.first {
			write(message: BluetoothService.EnableNotificationValue, for: descriptor)
		} else if characteristic.uuid == GATTBatteryLevel.uuid, let measurements = discoveredCharacteristics[GATTBloodPressureMeasurement.uuid], let descriptor = measurements.descriptors?.first {
			write(message: BluetoothService.EnableIndicationValue, for: descriptor)
		}
	}
}
