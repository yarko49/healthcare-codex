//
//  HealthKitManager+GlucoseMeter.swift
//  Allie
//
//  Created by Waqar Malik on 7/27/21.
//

import BluetoothService
import CareModel
import Combine
import CoreBluetooth
import Foundation
import HealthKit

extension BloodGlucoseRecord {
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
	func save(readings: [Int: BloodGlucoseReading], peripheral: Peripheral) -> AnyPublisher<[HKSample], Error> {
		let records: [Int: BloodGlucoseRecord] = readings.compactMapValues { reading in
			ALog.info("\(reading.measurement) \(reading.context)")
			let record = BloodGlucoseRecord(reading: reading)
			return record.isValid ? record : nil
		}
		return save(records: records, peripheral: peripheral)
	}

	func save(records: [Int: BloodGlucoseRecord], peripheral: Peripheral) -> AnyPublisher<[HKSample], Error> {
		Future { [weak self] promise in
			guard let strongSelf = self else {
				promise(.failure(AllieError.invalid("Self does not exist")))
				return
			}

			guard let name = peripheral.name else {
				promise(.failure(AllieError.missing("device name")))
				return
			}

			let recordsToAdd: [Int: BloodGlucoseRecord] = records.filter { (key: Int, _: BloodGlucoseRecord) in
				!strongSelf.sequenceNumbers.contains(number: key, forDevice: name)
			}

			guard !recordsToAdd.isEmpty else {
				promise(.success([]))
				return
			}

			let samples: [Int: HKQuantitySample] = recordsToAdd.mapValues { record in
				record.quantitySample
			}

			guard !samples.isEmpty else {
				promise(.success([]))
				return
			}

			let values = Array(samples.values)
				.sorted { lhs, rhs in
					lhs.endDate < rhs.endDate
				}

			self?.healthStore.save(values, withCompletion: { _, error in
				if let error = error {
					promise(.failure(error))
				} else {
					let keys = Set(samples.keys)
					self?.sequenceNumbers.insert(values: keys, forDevice: name)
					promise(.success(values))
					NotificationCenter.default.post(name: .didModifyHealthKitStore, object: nil)
				}
			})
		}.eraseToAnyPublisher()
	}

	func save(readings: [Int: BloodGlucoseReading], peripheral: Peripheral) async throws -> [HKSample] {
		let records: [Int: BloodGlucoseRecord] = readings.compactMapValues { reading in
			ALog.info("\(reading.measurement) \(reading.context)")
			let record = BloodGlucoseRecord(reading: reading)
			return record.isValid ? record : nil
		}
		return try await save(records: records, peripheral: peripheral)
	}

	func save(records: [Int: BloodGlucoseRecord], peripheral: Peripheral) async throws -> [HKSample] {
		guard let name = peripheral.name else {
			throw AllieError.missing("device name")
		}

		guard !records.isEmpty else {
			return []
		}

		let recordsToAdd: [Int: BloodGlucoseRecord] = records.filter { (key: Int, _: BloodGlucoseRecord) in
			!sequenceNumbers.contains(number: key, forDevice: name)
		}

		guard !recordsToAdd.isEmpty else {
			return []
		}

		let samples: [Int: HKQuantitySample] = recordsToAdd.mapValues { record in
			record.quantitySample
		}

		guard !samples.isEmpty else {
			return []
		}

		let values = Array(samples.values)
			.sorted { lhs, rhs in
				lhs.endDate < rhs.endDate
			}

		try await healthStore.save(values)
		let keys: Set<Int> = Set(samples.keys)
		sequenceNumbers.insert(values: keys, forDevice: name)
		NotificationCenter.default.post(name: .didModifyHealthKitStore, object: nil)
		return values
	}

	func fetchAllSequenceNumbers() async -> BGMSequenceNumbers<Int> {
		await withCheckedContinuation { [unowned self] checkedContinuation in
			fetchAllSequenceNumbers { result in
				checkedContinuation.resume(returning: result)
			}
		}
	}

	func fetchAllSequenceNumbers(completion: @escaping (BGMSequenceNumbers<Int>) -> Void) {
		let identifier = HealthKitQuantityType.bloodGlucose.healthKitQuantityType!
		let query = HKSampleQuery(sampleType: identifier, predicate: nil, limit: Int(Int32.max), sortDescriptors: nil) { _, results, error in
			var sequenceNumbers = BGMSequenceNumbers<Int>()
			if let error = error {
				ALog.error("could not find sequence number = \(error.localizedDescription)")
				completion(sequenceNumbers)
				return
			}

			results?.forEach { sample in
				if let deviceId = sample.metadata?[BGMMetadataKeyDeviceName] as? String, let number = sample.metadata?[BGMMetadataKeySequenceNumber] as? Int {
					sequenceNumbers.insert(value: number, forDevice: deviceId)
				}
			}

			completion(sequenceNumbers)
		}
		healthStore.execute(query)
	}

	func fetchSequenceNumbers(deviceId: String) async -> Set<Int> {
		await withCheckedContinuation { [unowned self] checkedContinuation in
			self.fetchSequenceNumbers(deviceId: deviceId) { sequenceNumbers in
				checkedContinuation.resume(returning: sequenceNumbers)
			}
		}
	}

	func maxSequenceNumber(deviceId: String) async -> Int {
		let sequenceNumbers = await fetchSequenceNumbers(deviceId: deviceId)
		return sequenceNumbers.max() ?? 0
	}

	func maxSequenceNumber(deviceId: String) -> AnyPublisher<Int, Never> {
		Future { [weak self] promise in
			self?.maxSequenceNumber(deviceId: deviceId) { sequnceNumber in
				promise(.success(sequnceNumber))
			}
		}.eraseToAnyPublisher()
	}

	func fetchSequenceNumbers(deviceId: String, completion: @escaping (Set<Int>) -> Void) {
		let identifier = HealthKitQuantityType.bloodGlucose.healthKitQuantityType!
		let query = HKSampleQuery(sampleType: identifier, predicate: nil, limit: Int(Int32.max), sortDescriptors: nil) { _, results, error in
			if let error = error {
				ALog.error("could not find sequence number = \(error.localizedDescription)")
				completion(Set<Int>())
				return
			}

			let sequenceNumbers = results?.compactMap { sample -> Int? in
				guard let metadata = sample.metadata else {
					return nil
				}

				guard let sampleDeviceId = metadata[BGMMetadataKeyDeviceName] as? String, sampleDeviceId == deviceId else {
					return nil
				}

				return metadata[BGMMetadataKeySequenceNumber] as? Int
			} ?? []

			completion(Set(sequenceNumbers))
		}
		healthStore.execute(query)
	}

	func maxSequenceNumber(deviceId: String, completion: @escaping (Int) -> Void) {
		fetchSequenceNumbers(deviceId: deviceId) { result in
			completion(result.max() ?? 0)
		}
	}
}
