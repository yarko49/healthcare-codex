//
//  BPMPairingViewController.swift
//  Allie
//
//  Created by Waqar Malik on 1/12/22.
//

import BluetoothService
import CodexFoundation
import OmronKit
import UIKit

class BPMPairingViewController: PairingViewController {
	override func viewDidLoad() {
		viewModel = PairingViewModel(pages: PairingItem.bloodPressureItems)
		super.viewDidLoad()
		titleLabel.text = NSLocalizedString("BLOOD_PRESSURE_PAIRING", comment: "Blood Pressure Pairing")
	}

	var deviceInfos: [UUID: OHQDeviceDiscoveryInfo] = [:]
	var devices: [UUID: OHQDevice] = [:]

	override var dicoveryServices: Set<CBUUID> {
		[GATTDeviceService.bloodPressure.id, GATTDeviceService.heartRate.id, GATTDeviceService.deviceInformation.id]
	}

	override var measurementCharacteristics: Set<CBUUID> {
		Set(GATTDeviceCharacteristic.bloodPressureMeasurements.map(\.uuid))
	}

	override func showSuccess() {
		super.showSuccess()
		NotificationCenter.default.post(name: .didPairBloodPressureMonitor, object: nil)
	}

	override func peripheral(_ peripheral: Peripheral, readyWith characteristic: CBCharacteristic) {
		if characteristic.uuid == GATTDeviceCharacteristic.bloodPressureFeature.uuid {
			peripheral.read(characteristic: characteristic, isBatched: false)
		}
	}

	override func updatePatient(peripheral: Peripheral) {
		if var patient = careManager.patient, let pairedPrepherial = try? CHPeripheral(device: peripheral, type: GATTDeviceService.bloodPressure.identifier) {
			patient.peripherals.insert(pairedPrepherial)
			careManager.patient = patient
			careManager.upload(patient: patient)
		}
	}
}
