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

	override var dicoveryServices: [CBUUID] {
		GATTServiceBloodPressure.services
	}

	override var measurementCharacteristics: [CBUUID] {
		GATTServiceBloodPressure.characteristics
	}

	override func peripheral(_ peripheral: Peripheral, readyWith characteristic: CBCharacteristic) {
		if characteristic.uuid == GATTBloodPressureFeature.uuid, !isPairing {
			isPairing = true
			peripheral.read(characteristic: characteristic, isBatched: false)
		}
	}

	override func updatePatient(peripheral: Peripheral) {
		if var patient = careManager.patient, let pairedPrepherial = try? CHPeripheral(peripheral: peripheral, type: GATTServiceBloodPressure.identifier) {
			patient.peripherals.insert(pairedPrepherial)
			careManager.patient = patient
			careManager.upload(patient: patient)
		}
	}
}
