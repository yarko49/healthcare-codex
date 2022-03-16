//
//  BGMPairingViewController.swift
//  Allie
//
//  Created by Waqar Malik on 8/23/21.
//

import BluetoothService
import CareModel
import CodexFoundation
import CoreBluetooth
import OmronKit
import UIKit

class BGMPairingViewController: PairingViewController {
	override func viewDidLoad() {
		deviceCategories = [.bloodGlucoseMonitor]
		super.viewDidLoad()
		titleLabel.text = NSLocalizedString("BLOOD_GLUCOSE_PAIRING", comment: "Blood Glucose Pairing")
	}

	deinit {
		syncManager.start()
	}

	override var dicoveryServices: [CBUUID] {
		GATTServiceBloodGlucose.services
	}

	override var measurementCharacteristics: [CBUUID] {
		GATTServiceBloodGlucose.characteristics
	}

	override func peripheral(_ peripheral: Peripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
		ALog.info("\(#function) characteristic: \(characteristic)")
		processValue(peripheral: peripheral, characteristic: characteristic, error: error)
	}

	override func deviceManager(_ manager: OHQDeviceManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
		guard bluetoothDevices[peripheral.identifier] == nil, let contains = peripheral.name?.lowercased().contains("contour"), contains else {
			return
		}

		let device = Peripheral(peripheral: peripheral, advertisementData: AdvertisementData(advertisementData: advertisementData), rssi: RSSI)
		device.delegate = self
		bluetoothDevices[device.identifier] = device
		DispatchQueue.main.async { [weak self] in
			guard let strongSelf = self else {
				return
			}
			strongSelf.deviceNameLabel.text = device.name
			strongSelf.setContinueButton(enabled: true)
			if strongSelf.currentPageIndex != 1 {
				strongSelf.scroll(toPage: 1, direction: strongSelf.currentPageIndex < 1 ? .forward : .reverse, animated: true, completion: nil)
			}
		}
	}

	override func peripheral(_ peripheral: Peripheral, readyWith characteristic: CBCharacteristic) {
		if characteristic.uuid == GATTRecordAccessControlPoint.uuid, !isPairing {
			isPairing = true
			peripheral.writeMessage(characteristic: characteristic, message: GATTRecordAccessControlPoint.numberOfRecords, isBatched: true)
		}
	}

	override func processValue(peripheral: Peripheral, characteristic: CBCharacteristic, error: Error?) {
		ALog.info("\(#function) characteristic: \(characteristic)")
		isPairing = false
		if let error = error {
			ALog.error("pairing device", error: error)
			let nsError = error as NSError
			ALog.error("nsError = \(nsError)")
			if nsError.code == 15 || nsError.code == 3, nsError.domain == "CBATTErrorDomain" {
				DispatchQueue.main.async { [weak self] in
					self?.showFailure()
				}
			}
		} else {
			DispatchQueue.main.async { [weak self] in
				self?.showSuccess(completion: { _ in
					self?.updatePatient(peripheral: peripheral)
				})
			}
		}
	}

	override func updatePatient(peripheral: Peripheral) {
		if var patient = careManager.patient, let pairedPrepherial = try? CHPeripheral(peripheral: peripheral, type: GATTServiceBloodGlucose.identifier) {
			patient.peripherals[pairedPrepherial.type] = pairedPrepherial
			careManager.patient = patient
			careManager.upload(patient: patient)
		}
	}
}
