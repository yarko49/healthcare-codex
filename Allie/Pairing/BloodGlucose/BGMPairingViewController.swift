//
//  BGMPairingViewController.swift
//  Allie
//
//  Created by Waqar Malik on 8/23/21.
//

import BluetoothService
import CodexFoundation
import CoreBluetooth
import OmronKit
import UIKit

class BGMPairingViewController: PairingViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		titleLabel.text = NSLocalizedString("BLOOD_GLUCOSE_PAIRING", comment: "Blood Glucose Pairing")
	}

	override var dicoveryServices: [CBUUID] {
		GATTServiceBloodGlucose.services
	}

	override var measurementCharacteristics: [CBUUID] {
		GATTServiceBloodGlucose.characteristics
	}

	override func deviceManager(_ manager: OHQDeviceManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
		guard bluetoothDevices[peripheral.identifier] == nil, let contains = peripheral.name?.lowercased().contains("contour"), contains else {
			return
		}
		let device = Peripheral(peripheral: peripheral, advertisementData: AdvertisementData(advertisementData: advertisementData), rssi: RSSI)
		device.delegate = self
		bluetoothDevices[device.identifier] = device
		DispatchQueue.main.async { [weak self] in
			self?.scroll(toPage: 2, direction: .forward, animated: true) { finished in
				ALog.info("Bluetooth Finished Scrolling to pairing \(finished)")
				ALog.info("Bluetooth Connecting to")
				manager.stopScan()
				manager.connectPerpherial(peripheral, withOptions: nil)
			}
		}
	}

	override func peripheral(_ peripheral: Peripheral, readyWith characteristic: CBCharacteristic) {
		if characteristic.uuid == GATTRecordAccessControlPoint.uuid, !isPairing {
			isPairing = true
			peripheral.writeMessage(characteristic: characteristic, message: GATTRecordAccessControlPoint.numberOfRecords, isBatched: true)
		}
	}

	override func showSuccess() {
		super.showSuccess()
		NotificationCenter.default.post(name: .didPairBluetoothDevice, object: nil)
	}

	override func updatePatient(peripheral: Peripheral) {
		if var patient = careManager.patient, let pairedPrepherial = try? CHPeripheral(peripheral: peripheral, type: GATTServiceBloodGlucose.identifier) {
			patient.peripherals.insert(pairedPrepherial)
			careManager.patient = patient
			careManager.upload(patient: patient)
		}
	}
}
