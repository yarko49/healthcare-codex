//
//  NewDailyTasks+BloodGlucoseMonitor.swift
//  Allie
//
//  Created by Onseen on 1/29/22.
//

import Foundation
import HealthKit
import UIKit
import CoreBluetooth

extension NewDailyTasksPageViewController: BGMBluetoothManagerDelegate {
    func startBluetooth() {
        bloodGlucoseMonitor.multicastDelegate.add(self)
        bloodGlucoseMonitor.startMonitoring()
    }

    func bluetoothManager(_ manager: BGMBluetoothManager, didUpdate state: CBManagerState) {
        ALog.info("Bluetooth state = \(state)")
        let state: Bool = state == .poweredOn ? true : false
        if state {
            ALog.info("Bluetooth Active")
            bloodGlucoseMonitor.scanForPeripherals()
            ALog.info("Starting BLE scan\n")
        } else {
            ALog.error("Bluetooth Start Error")
        }
    }

    func bluetoothManager(_ manager: BGMBluetoothManager, didFind peripheral: CBPeripheral, rssi: Int) {
        if let currentDevice = careManager.patient?.bgmName, peripheral.name == currentDevice {
            bloodGlucoseMonitor.connect(peripheral: peripheral)
            return
        }

        guard !manager.peripherals.contains(peripheral) else {
            return
        }
        manager.peripherals.insert(peripheral)
    }

    func bluetoothManager(_ manager: BGMBluetoothManager, peripheral: CBPeripheral, readyWith characteristic: CBCharacteristic) {
        manager.racpCharacteristic = characteristic
        if let glucometer = manager.pairedPeripheral, let racp = manager.racpCharacteristic, let identifier = glucometer.name {
            healthKitManager.fetchSequenceNumbers(deviceId: identifier) { [weak self] values in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.healthKitManager.sequenceNumbers.insert(values: values, forDevice: identifier)
                var command = GATTCommand.allRecords
                if let maxSequenceNumber = strongSelf.healthKitManager.sequenceNumbers.max(forDevice: identifier), maxSequenceNumber > 0 {
                    command = GATTCommand.recordStart(sequenceNumber: maxSequenceNumber)
                }
                strongSelf.bloodGlucoseMonitor.writeMessage(peripheral: glucometer, characteristic: racp, message: command, isBatched: true)
            }
        }
    }

    func bluetoothManager(_ manager: BGMBluetoothManager, peripheral: CBPeripheral, didReceive readings: [Int: BGMDataReading]) {
        ALog.info("didReceive readings \(readings)")
        healthKitManager.save(readings: readings, peripheral: peripheral)
            .sinkOnMain { [weak self] completionResult in
                if case .failure(let error) = completionResult {
                    ALog.error("Error saving data to health kit \(error.localizedDescription)", error: error)
                    let title = NSLocalizedString("ERROR", comment: "Error")
                    self?.showErrorAlert(title: title, message: error.localizedDescription)
                }
            } receiveValue: { [weak self] samples in
                self?.updatePatient(manager: manager, peripheral: peripheral)
                self?.process(samples: samples, quantityIdentifier: .bloodGlucose)
            }.store(in: &cancellables)
    }

    func updatePatient(manager: BGMBluetoothManager, peripheral: CBPeripheral) {
        guard var patient = careManager.patient else {
            return
        }
        let date = Date()
        let seconds = date.timeIntervalSince1970
        let millisecondsString = String(Int64(seconds * 1000))
        let dateString = DateFormatter.wholeDateRequest.string(from: date)
        patient.bgmIdentifier = peripheral.identifier.uuidString
        patient.bgmName = peripheral.name
        patient.bgmLastSync = millisecondsString
        patient.bgmLastSyncDate = dateString
        careManager.patient = patient
        careManager.upload(patient: patient)
    }

    func process(samples: [HKSample], quantityIdentifier: HKQuantityTypeIdentifier) {
        let uploadEndDate = UserDefaults.standard[healthKitOutcomesUploadDate: quantityIdentifier.rawValue]
        let samplesToUpload = samples.filter { sample in
            sample.startDate <= uploadEndDate
        }

        careManager.upload(samples: samplesToUpload, quantityIdentifier: quantityIdentifier)
            .sinkOnMain { completionResult in
                if case .failure(let error) = completionResult {
                    ALog.error("Error uploading outcomes", error: error)
                }
            } receiveValue: { [weak self] outcomes in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.careManager.save(outcomes: outcomes)
                    .sinkOnMain { completionResult in
                        if case .failure(let error) = completionResult {
                            ALog.error("Error saving outcomes", error: error)
                        }
                    } receiveValue: { _ in
                        ALog.info("Saved outcomes")
                    }.store(in: &strongSelf.cancellables)
            }.store(in: &cancellables)
    }

    func showBGMFoundAlert(device: CBPeripheral) {
        let title = NSLocalizedString("BGM_DETECTED", comment: "Glucose meter detected!")
        let message = NSLocalizedString("BGM_DETECTED.message", comment: "Would you like to connect to the following device:") + "\n\n" + (device.name ?? "Contour Diabetes Meter")
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Cancel"), style: .cancel) { [weak self] _ in
            self?.bloodGlucoseMonitor.peripherals.insert(device)
        }
        alertController.addAction(cancelAction)
        let connectAction = UIAlertAction(title: NSLocalizedString("CONNECT", comment: "Connect"), style: .default) { [weak self] _ in
            guard self?.careManager.patient?.bgmName == nil else {
                self?.showCannotPair()
                return
            }
            self?.showConnectFlow(identifier: device.identifier.uuidString)
        }
        alertController.addAction(connectAction)
        (tabBarController ?? navigationController ?? self).showDetailViewController(alertController, sender: self)
    }

    func showCannotPair() {
        let title = NSLocalizedString("BGM_CANNOT_PAIR", comment: "Cannot pair another device")
        let message = NSLocalizedString("BGM_CANNOT_PAIR.message", comment: "Only one device of this type can be paired at once. Please disconnect your previous device to connect this new one.")
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Ok"), style: .default) { _ in
        }
        alertController.addAction(okAction)
        (tabBarController ?? navigationController ?? self).showDetailViewController(alertController, sender: self)
    }

    func showErrorAlert(title: String, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Ok"), style: .default) { _ in
        }
        alertController.addAction(okAction)
        (tabBarController ?? navigationController ?? self).showDetailViewController(alertController, sender: self)
    }

    func showConnectFlow(identifier: String) {
        let viewController = BGMPairingViewController()
        viewController.modalPresentationStyle = .fullScreen
        viewController.delegate = self
        viewController.selectedIdentifier = identifier
        (tabBarController ?? navigationController ?? self).showDetailViewController(viewController, sender: self)
    }
}

extension NewDailyTasksPageViewController: BGMPairingViewControllerDelegate {
    func pairingViewControllerDidFinish(_ controller: BGMPairingViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

    func pairingViewControllerDidCancel(_ controller: BGMPairingViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
