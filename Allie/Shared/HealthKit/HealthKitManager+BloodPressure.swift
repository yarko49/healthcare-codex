//
//  HealthKitManager+BloodPressure.swift
//  Allie
//
//  Created by Waqar Malik on 1/4/22.
//

import Combine
import Foundation
import HealthKit

extension HealthKitManager {
	func bloodPressure(startDate: Date, endDate: Date, options: HKQueryOptions) -> AnyPublisher<[HKSample], Error> {
		Future { [weak self] promise in
			self?.bloodPressure(startDate: startDate, endDate: endDate, options: options, completion: { result in
				switch result {
				case .failure(let error):
					promise(.failure(error))
				case .success(let samples):
					promise(.success(samples))
				}
			})
		}.eraseToAnyPublisher()
	}

	func bloodPressure(startDate: Date, endDate: Date, options: HKQueryOptions, completion: @escaping AllieResultCompletion<[HKSample]>) {
		guard let bloodPressure = HKQuantityType.correlationType(forIdentifier: .bloodPressure) else {
			completion(.failure(HealthKitManagerError.invalidInput("CorrelationType not valid BloodPressure")))
			return
		}
		let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: options)
		let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
		let query = HKSampleQuery(sampleType: bloodPressure, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, results, error in
			guard let samples = results, error == nil else {
				completion(.failure(error ?? HealthKitManagerError.dataTypeNotAvailable))
				return
			}
			completion(.success(samples))
		}
		healthStore.execute(query)
	}

	func bloodPressure(startDate: Date, endDate: Date, options: HKQueryOptions) async throws -> [HKSample] {
		try await withCheckedThrowingContinuation { checkedContinuation in
			bloodPressure(startDate: startDate, endDate: endDate, options: options) { result in
				checkedContinuation.resume(with: result)
			}
		}
	}
}
