//
//  WSPairingViewController.swift
//  Allie
//
//  Created by Waqar Malik on 2/16/22.
//

import BluetoothService
import CareModel
import CodexFoundation
import OmronKit
import UIKit

class WSPairingViewController: PairingViewController {
	override func viewDidLoad() {
		deviceCategories = [.bodyCompositionMonitor, .weightScale]
		viewModel = PairingViewModel(pages: PairingItem.weightScaleItems)
		super.viewDidLoad()
		titleLabel.text = NSLocalizedString("WEIGHT_SCALE_PAIRING", comment: "Scale Pairing")
	}

	override var dicoveryServices: [CBUUID] {
		GATTServiceWeightScale.services
	}

	override var measurementCharacteristics: [CBUUID] {
		GATTServiceWeightScale.characteristics
	}

	override func peripheral(_ peripheral: Peripheral, readyWith characteristic: CBCharacteristic) {
		ALog.info("\(#function) \(peripheral)")
		if characteristic.uuid == GATTWeightScaleFeature.uuid, !isPairing {
			isPairing = true
			peripheral.read(characteristic: characteristic, isBatched: false)
		}
	}

	override func updatePatient(peripheral: Peripheral) {
		if var patient = careManager.patient, let pairedPrepherial = try? CHPeripheral(peripheral: peripheral, type: GATTServiceWeightScale.identifier) {
			patient.peripherals[pairedPrepherial.type] = pairedPrepherial
			careManager.patient = patient
			careManager.upload(patient: patient)
		}
	}
}
