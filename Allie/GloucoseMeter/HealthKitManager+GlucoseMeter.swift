//
//  HealthKitManager+GlucoseMeter.swift
//  Allie
//
//  Created by Waqar Malik on 7/27/21.
//

import Combine
import Foundation
import HealthKit

let BGMMetadataKeySequenceNumber = "BGMSequenceNumber"
let BGMMetadataKeyBloodType = "BGMBloodSampleType"
let BGMMetadataKeySampleLocation = "BGMSampleLocation"
let BGMMetadataKeyDeviceName = "BGMDeviceName"
let BGMMetadataKeyDeviceId = "BGMDeviceId"
let BGMMetadataKeyMeasurementRecord = "BMGMeasurementRecord"
let BGMMetadataKeyContextRecord = "BGMContextRecord"

extension BGMDataRecord {
	var metadata: [String: Any] {
		var metadata: [String: Any] = [HKMetadataKeyTimeZone: timeZone.identifier,
		                               BGMMetadataKeySequenceNumber: NSNumber(value: sequence),
		                               BGMMetadataKeyBloodType: sampleType,
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
	func save(readings: [BGMDataReading]) -> AnyPublisher<Bool, Error> {
		let records: [BGMDataRecord] = readings.map { reading in
			ALog.info("\(reading.measurement) \(reading.context)")
			return BGMDataRecord(reading: reading)
		}
		return save(records: records)
	}

	func save(records: [BGMDataRecord]) -> AnyPublisher<Bool, Error> {
		Future { [weak self] promise in
			let samples: [HKQuantitySample] = records.map { record in
				record.quantitySample
			}.sorted { lhs, rhs in
				lhs.endDate < rhs.endDate
			}
			if let sequence = samples.first?.metadata?[BGMMetadataKeySequenceNumber] as? NSNumber {
				self?.lastBGMSequenceNumber = sequence.intValue
			}
			promise(.success(true))
			self?.healthStore.save(samples, withCompletion: { result, error in
				if let error = error {
					promise(.failure(error))
				} else {
					promise(.success(result))
				}
			})
		}.eraseToAnyPublisher()
	}

	func findSequenceNumber() -> AnyPublisher<Int, Never> {
		Future { [weak self] promise in
			self?.findSequenceNumber { result in
				switch result {
				case .failure(let error):
					ALog.error("Sequence Number not found", error: error)
					promise(.success(0))
				case .success(let sequence):
					promise(.success(sequence))
				}
			}
		}.eraseToAnyPublisher()
	}

	func findSequenceNumber(completion: @escaping AllieResultCompletion<Int>) {
		let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false) // StartDate is date when record enetered not the date in the record itself
		let identifier = HealthKitQuantityType.bloodGlucose.healthKitQuantityType!
		let query = HKSampleQuery(sampleType: identifier, predicate: nil, limit: 10, sortDescriptors: [sortDescriptor]) { _, results, error in
			if let error = error {
				completion(.failure(error))
				return
			}

			guard let result = results?.first as? HKQuantitySample else {
				completion(.failure(HealthKitManagerError.dataTypeNotAvailable))
				return
			}

			guard let sequenceNumber = result.metadata?[BGMMetadataKeySequenceNumber] as? NSNumber else {
				completion(.failure(HealthKitManagerError.dataTypeNotAvailable))
				return
			}

			completion(.success(sequenceNumber.intValue))
		}
		healthStore.execute(query)
	}
}
