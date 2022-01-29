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
		[GATTDeviceService.bloodPressure.id]
	}

	override var measurementCharacteristics: Set<CBUUID> {
		Set(GATTDeviceCharacteristic.bloodPressureMeasurements.map(\.uuid))
	}

	override var notifyCharacteristics: Set<CBUUID> {
		[GATTDeviceCharacteristic.bloodPressureMeasurement.uuid]
	}

	override func bluetoothService(_ service: BluetoothService, didDiscover peripheral: Peripheral) {
		guard bluetoothDevices[peripheral.identifier] == nil else {
			return
		}
		peripheral.delegate = self
		bluetoothDevices[peripheral.identifier] = peripheral
		DispatchQueue.main.async { [weak self] in
			self?.scroll(toPage: 2, direction: .forward, animated: true) { finished in
				ALog.info("Bluetooth Finished Scrolling to pairing \(finished)")
				ALog.info("Bluetooth Connecting to")
				service.connect(peripheral: peripheral)
			}
		}
	}

	override func showSuccess() {
		super.showSuccess()
		NotificationCenter.default.post(name: .didPairBloodPressureMonitor, object: nil)
	}
}
