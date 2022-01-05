//
//  HealthKitManager+Samples.swift
//  Allie
//
//  Created by Waqar Malik on 1/4/22.
//

import Combine
import Foundation
import HealthKit

extension HealthKitManager {
	func sample(dataType: HealthKitDataType, startDate: Date, endDate: Date, options: HKQueryOptions) -> AnyPublisher<[HKSample], Error> {
		if dataType == .bloodPressure {
			return bloodPressure(startDate: startDate, endDate: endDate, options: options)
		} else {
			guard let firstSampleType = dataType.quantityType.first, let sampleType = firstSampleType else {
				return Fail(error: HealthKitManagerError.invalidInput("DataType \(dataType.rawValue) missing sample type"))
					.eraseToAnyPublisher()
			}
			return samples(for: sampleType, startDate: startDate, endDate: endDate, options: options)
		}
	}

	func sample(dataType: HealthKitDataType, startDate: Date, endDate: Date, options: HKQueryOptions, completion: @escaping AllieResultCompletion<[HKSample]>) {
		if dataType == .bloodPressure {
			bloodPressure(startDate: startDate, endDate: endDate, options: options, completion: completion)
		} else {
			guard let firstSampleType = dataType.quantityType.first, let sampleType = firstSampleType else {
				completion(.failure(HealthKitManagerError.invalidInput("DataType \(dataType.rawValue) missing sample type")))
				return
			}
			samples(for: sampleType, startDate: startDate, endDate: endDate, options: options, completion: completion)
		}
	}

	func sample(dataType: HealthKitDataType, startDate: Date, endDate: Date, options: HKQueryOptions) async throws -> [HKSample] {
		if dataType == .bloodPressure {
			return try await bloodPressure(startDate: startDate, endDate: endDate, options: options)
		} else if let firstSampleType = dataType.quantityType.first, let sampleType = firstSampleType {
			return try await samples(for: sampleType, startDate: startDate, endDate: endDate, options: options)
		} else {
			throw HealthKitManagerError.invalidInput("DataType \(dataType.rawValue) missing sample type")
		}
	}

	func samples(for quantityType: HKQuantityType, startDate: Date, endDate: Date, options: HKQueryOptions) -> AnyPublisher<[HKSample], Error> {
		Future { [weak self] promise in
			self?.samples(for: quantityType, startDate: startDate, endDate: endDate, options: options, completion: { result in
				switch result {
				case .failure(let error):
					promise(.failure(error))
				case .success(let samples):
					promise(.success(samples))
				}
			})
		}.eraseToAnyPublisher()
	}

	func samples(for quantityType: HKQuantityType, startDate: Date, endDate: Date, options: HKQueryOptions, completion: @escaping AllieResultCompletion<[HKSample]>) {
		let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: options)
		let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
		let query = HKSampleQuery(sampleType: quantityType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, results, error in
			guard let samples = results, error == nil else {
				completion(.failure(error ?? HealthKitManagerError.dataTypeNotAvailable))
				return
			}
			completion(.success(samples))
		}
		healthStore.execute(query)
	}

	func samples(for quantityType: HKQuantityType, startDate: Date, endDate: Date, options: HKQueryOptions) async throws -> [HKSample] {
		try await withCheckedThrowingContinuation { checkedContinuation in
			samples(for: quantityType, startDate: startDate, endDate: endDate, options: options) { result in
				checkedContinuation.resume(with: result)
			}
		}
	}

	func mostRecentSample(for identifier: HKQuantityTypeIdentifier, options: HKQueryOptions) -> AnyPublisher<[HKSample], Error> {
		Future { [weak self] promise in
			self?.mostRecentSample(for: identifier, options: options, completion: { result in
				switch result {
				case .failure(let error):
					promise(.failure(error))
				case .success(let samples):
					promise(.success(samples))
				}
			})
		}.eraseToAnyPublisher()
	}

	func mostRecentSample(for identifier: HKQuantityTypeIdentifier, options: HKQueryOptions, completion: @escaping AllieResultCompletion<[HKSample]>) {
		guard let type = HKSampleType.quantityType(forIdentifier: identifier) else {
			completion(.failure(HealthKitManagerError.invalidInput("SampleType not valid \(identifier.rawValue)")))
			return
		}
		let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: [])
		let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
		let limit = 1
		let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: limit, sortDescriptors: [sortDescriptor]) { _, samples, error in
			guard let sample = samples, error == nil else {
				completion(.failure(error ?? HealthKitManagerError.dataTypeNotAvailable))
				return
			}
			completion(.success(sample))
		}
		healthStore.execute(query)
	}

	func mostRecentSample(for identifier: HKQuantityTypeIdentifier, options: HKQueryOptions) async throws -> [HKSample] {
		try await withCheckedThrowingContinuation { checkedContinuation in
			mostRecentSample(for: identifier, options: options) { result in
				checkedContinuation.resume(with: result)
			}
		}
	}
}
