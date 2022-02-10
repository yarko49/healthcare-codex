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
import AscensiaKit
import BluetoothService
import CareKitStore

extension NewDailyTasksPageViewController: BluetoothServiceDelegate {
    var supportedServices: Set<CBUUID> {
        [GATTDeviceService.bloodGlucose.id, GATTDeviceService.bloodPressure.id]
    }

    var measurementCharacteristics: Set<CBUUID> {
        Set(GATTDeviceCharacteristic.bloodGlucoseMeasurements.map(\.uuid))
    }

    func bluetoothService(_ service: BluetoothService, didUpdate state: CBManagerState) {
        ALog.info("Bluetooth state = \(state.rawValue)")
        let state: Bool = state == .poweredOn ? true : false
        if state {
            ALog.info("Bluetooth Active")
            // let options: [String: Any] = [CBCentralManagerScanOptionAllowDuplicatesKey: true
            bluetoothService.scanForPeripherals(services: supportedServices)
            ALog.info("Starting BLE scan\n")
        } else {
            ALog.error("Bluetooth Start Error")
        }
    }

    func startBluetooth() {
        bluetoothService.addDelegate(self)
        bluetoothService.startMonitoring()
    }

    func bluetoothService(_ service: BluetoothService, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if let currentDevice = careManager.patient?.bloodGlucoseMonitor, peripheral.name == currentDevice.id {
            let device = AKDevice(peripheral: peripheral, advertisementData: AdvertisementData(advertisementData: advertisementData), rssi: RSSI)
            device.delegate = self
            device.dataSource = self
            bluetoothDevices[device.identifier] = device
            bluetoothService.connect(peripheral: peripheral)
            return
        }
    }

    func bluetoothService(_ service: BluetoothService, didConnect peripheral: CBPeripheral) {
        ALog.info("\(#function) \(peripheral)")
        guard let deviceManager = bluetoothDevices[peripheral.identifier] else {
            return
        }
        deviceManager.discover(services: supportedServices, measurementCharacteristics: measurementCharacteristics)
    }

    func bluetoothService(_ service: BluetoothService, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        bluetoothDevices.removeValue(forKey: peripheral.identifier)
        service.startMonitoring()
    }

    func bluetoothService(_ service: BluetoothService, didDisconnect peripheral: CBPeripheral, error: Error?) {
        bluetoothDevices.removeValue(forKey: peripheral.identifier)
        service.startMonitoring()
    }
}

extension NewDailyTasksPageViewController: PeripheralDelegate {
    func peripheral(_ peripheral: Peripheral, readyWith characteristic: CBCharacteristic) {
        if let glucometer = bluetoothDevices[peripheral.identifier], let identifier = glucometer.name {
            glucometer.racpCharacteristic = characteristic
            healthKitManager.fetchSequenceNumbers(deviceId: identifier) { [weak self] values in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.healthKitManager.sequenceNumbers.insert(values: values, forDevice: identifier)
                let maxSequenceNumber = strongSelf.healthKitManager.sequenceNumbers.max(forDevice: identifier)
                glucometer.fetchRecords(startSequenceNumber: maxSequenceNumber)
            }
        }
    }
}

extension NewDailyTasksPageViewController: AKDeviceDataSource {
    func device(_ device: AKDevice, didReceive readings: [Int: AKBloodGlucoseReading]) {
        ALog.info("didReceive readings \(readings)")
        Task { [unowned self] in
            do {
                let samples = try await self.healthKitManager.save(readings: readings, peripheral: device)
                self.updatePatient(peripheral: device)
                _ = try await self.process(samples: samples, quantityIdentifier: .bloodGlucose)
            } catch {
                ALog.error("Error saving data to health kit \(error.localizedDescription)", error: error)
                DispatchQueue.main.async {
                    let title = NSLocalizedString("ERROR", comment: "Error")
                    self.showErrorAlert(title: title, message: error.localizedDescription)
                }
            }
        }
    }

    func updatePatient(peripheral: Peripheral) {
        guard var patient = careManager.patient, var pairedPeripheral = patient.peripheral(device: peripheral) else {
            return
        }
        patient.peripherals.remove(pairedPeripheral)
        let date = Date()
        let seconds = date.timeIntervalSince1970
        let millisecondsString = String(Int64(seconds * 1000))
        pairedPeripheral.lastSync = millisecondsString
        pairedPeripheral.lastSyncDate = date
        patient.peripherals.insert(pairedPeripheral)
        careManager.patient = patient
        careManager.upload(patient: patient)
    }

    func process(samples: [HKSample], quantityIdentifier: HKQuantityTypeIdentifier) async throws -> [OCKOutcome] {
        let uploadEndDate = UserDefaults.standard[healthKitOutcomesUploadDate: quantityIdentifier.rawValue]
        let samplesToUpload = samples.filter { sample in
            sample.startDate <= uploadEndDate
        }
        let outcomes = try await careManager.upload(samples: samplesToUpload, quantityIdentifier: quantityIdentifier)
        return try await careManager.save(outcomes: outcomes)
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

    func showBGMFoundAlert(device: Peripheral) {
        let title = NSLocalizedString("BGM_DETECTED", comment: "Glucose meter detected!")
        let message = NSLocalizedString("BGM_DETECTED.message", comment: "Would you like to connect to the following device:") + "\n\n" + (device.name ?? "Contour Diabetes Meter")
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Cancel"), style: .cancel) { [weak self] _ in
            // self?.bluetoothManager.discoveredPeripherals[device.identifier] = device
        }
        alertController.addAction(cancelAction)
        let connectAction = UIAlertAction(title: NSLocalizedString("CONNECT", comment: "Connect"), style: .default) { [weak self] _ in
            guard self?.careManager.patient?.peripheral(serviceType: GATTDeviceService.bloodGlucose.identifier) == nil else {
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

extension NewDailyTasksPageViewController: PairingViewControllerDelegate {
    func pairingViewControllerDidCancel(_ controller: PairingViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

    func pairingViewControllerDidFinish(_ controller: PairingViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
