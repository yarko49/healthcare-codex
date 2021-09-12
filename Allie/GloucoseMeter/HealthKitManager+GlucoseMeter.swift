//
//  HealthKitManager+GlucoseMeter.swift
//  Allie
//
//  Created by Waqar Malik on 7/27/21.
//

import Combine
import CoreBluetooth
import Foundation
import HealthKit

let BGMMetadataKeySequenceNumber = "BGMSequenceNumber"
let BGMMetadataKeyBloodSampleType = "BGMBloodSampleType"
let BGMMetadataKeySampleLocation = "BGMSampleLocation"
let BGMMetadataKeyDeviceName = "BGMDeviceName"
let BGMMetadataKeyDeviceId = "BGMDeviceId"
let BGMMetadataKeyMeasurementRecord = "BMGMeasurementRecord"
let BGMMetadataKeyContextRecord = "BGMContextRecord"

extension BGMDataRecord {
	var metadata: [String: Any] {
		var metadata: [String: Any] = [HKMetadataKeyTimeZone: timeZone.identifier,
		                               BGMMetadataKeySequenceNumber: NSNumber(value: sequence),
		                               BGMMetadataKeyBloodSampleType: sampleType,
		                               BGMMetadataKeySampleLocation: sampleLocation,
		                               HKMetadataKeyWasUserEntered: NSNumber(value: false)]

		metadata[CHMetadataKeyBloodGlucoseMealTime] = NSNumber(value: mealTime.rawValue)
		if mealTime == .preprandial || mealTime == .postprandial {
			metadata[HKMetadataKeyBloodGlucoseMealTime] = NSNumber(value: mealTime.rawValue)
		}
		if let deviceName = peripheral?.name {
			metadata[BGMMetadataKeyDeviceName] = deviceName
		}
		if let deviceId = peripheral?.identifier.uuidString {
			metadata[BGMMetadataKeyDeviceId] = deviceId
		}
		let measurementRecord = measurementData.base64EncodedString()
		metadata[BGMMetadataKeyMeasurementRecord] = measurementRecord
		if let contextRecord = contextData?.base64EncodedString() {
			metadata[BGMMetadataKeyContextRecord] = contextRecord
		}
		return metadata
	}

	var quantitySample: HKQuantitySample {
		let quantity = HKQuantity(unit: HealthKitQuantityType.bloodGlucose.hkUnit, doubleValue: glucoseConcentration)
		let identifier = HealthKitQuantityType.bloodGlucose.healthKitQuantityType!
		let sampleData = HKQuantitySample(type: identifier, quantity: quantity, start: utcTimestamp, end: utcTimestamp, metadata: metadata)
		return sampleData
	}
}

extension HealthKitManager {
	func save(readings: [BGMDataReading], peripheral: CBPeripheral) -> AnyPublisher<[HKSample], Error> {
		let records: [BGMDataRecord] = readings.map { reading in
			ALog.info("\(reading.measurement) \(reading.context)")
			return BGMDataRecord(reading: reading)
		}
		return save(records: records, peripheral: peripheral)
	}

	func save(records: [BGMDataRecord], peripheral: CBPeripheral) -> AnyPublisher<[HKSample], Error> {
		Future { [weak self] promise in
			guard let name = peripheral.name else {
				promise(.failure(AllieError.missing("device name")))
				return
			}
			self?.findSequenceNumber(deviceId: name) { sequenceNumber in
				let newRecords = records.filter { record in
					record.sequence > sequenceNumber
				}

				let samples: [HKQuantitySample] = newRecords.map { record in
					record.quantitySample
				}.sorted { lhs, rhs in
					lhs.endDate < rhs.endDate
				}
				guard !samples.isEmpty else {
					promise(.success([]))
					return
				}
				self?.healthStore.save(samples, withCompletion: { _, error in
					if let error = error {
						promise(.failure(error))
					} else {
						promise(.success(samples))
					}
				})
			}
		}.eraseToAnyPublisher()
	}

	func findSequenceNumber(deviceId: String) -> AnyPublisher<Int, Never> {
		Future { [weak self] promise in
			self?.findSequenceNumber(deviceId: deviceId) { sequnceNumber in
				promise(.success(sequnceNumber))
			}
		}.eraseToAnyPublisher()
	}

	func findSequenceNumber(deviceId: String, completion: @escaping (Int) -> Void) {
		let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false) // StartDate is date when record enetered not the date in the record itself
		let identifier = HealthKitQuantityType.bloodGlucose.healthKitQuantityType!
		let query = HKSampleQuery(sampleType: identifier, predicate: nil, limit: 20, sortDescriptors: [sortDescriptor]) { _, results, error in
			if let error = error {
				ALog.error("could not find sequence number = \(error.localizedDescription)")
			}

			let sequenceNumber = results?.compactMap { sample -> Int? in
				guard let metadata = sample.metadata else {
					return nil
				}

				guard let sampleDeviceId = metadata[BGMMetadataKeyDeviceName] as? String, sampleDeviceId == deviceId else {
					return nil
				}

				return metadata[BGMMetadataKeySequenceNumber] as? Int
			}.max() ?? 0

			completion(sequenceNumber)
		}
		healthStore.execute(query)
	}
}
