//
//  BGMPairingViewController.swift
//  Allie
//
//  Created by Waqar Malik on 8/23/21.
//

import AscensiaKit
import BluetoothService
import CodexFoundation
import CoreBluetooth
import UIKit

class BGMPairingViewController: PairingViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		titleLabel.text = NSLocalizedString("BLOOD_GLUCOSE_PAIRING", comment: "Blood Glucose Pairing")
	}

	override var dicoveryServices: Set<CBUUID> {
		[GATTDeviceService.bloodGlucose.id]
	}

	override var measurementCharacteristics: Set<CBUUID> {
		Set(GATTDeviceCharacteristic.bloodGlucoseMeasurements.map(\.uuid))
	}

	override var notifyCharacteristics: Set<CBUUID> {
		[GATTDeviceCharacteristic.recordAccessControlPoint.uuid]
	}

	override func bluetoothService(_ service: BluetoothService, didDiscover peripheral: Peripheral) {
		guard bluetoothDevices[peripheral.identifier] == nil else {
			return
		}
		let device = AKDevice(peripheral: peripheral)
		device.delegate = self
		bluetoothDevices[device.identifier] = device
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
		NotificationCenter.default.post(name: .didPairBloodGlucoseMonitor, object: nil)
	}
}
