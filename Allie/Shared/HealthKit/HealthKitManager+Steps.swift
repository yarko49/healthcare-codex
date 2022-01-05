//
//  HealthKitManager+Steps.swift
//  Allie
//
//  Created by Waqar Malik on 1/4/22.
//

import Combine
import Foundation
import HealthKit

extension HealthKitManager {
	func stepCount(startDate: Date, endDate: Date, options: HKQueryOptions) -> AnyPublisher<[HKStatistics], Error> {
		Future { [weak self] promise in
			self?.stepCount(startDate: startDate, endDate: endDate, options: options) { result in
				switch result {
				case .failure(let error):
					promise(.failure(error))
				case .success(let statistics):
					promise(.success(statistics))
				}
			}
		}.eraseToAnyPublisher()
	}

	func stepCount(startDate: Date, endDate: Date, options: HKQueryOptions, completion: @escaping AllieResultCompletion<[HKStatistics]>) {
		let type = HKSampleType.quantityType(forIdentifier: .stepCount)
		let beginingOfDay = Calendar.current.startOfDay(for: startDate)
		var interval = DateComponents()
		interval.day = 1
		let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: options)
		let query = HKStatisticsCollectionQuery(quantityType: type!, quantitySamplePredicate: predicate, options: [.cumulativeSum, .separateBySource], anchorDate: beginingOfDay, intervalComponents: interval)
		query.initialResultsHandler = { _, results, error in
			if let error = error {
				completion(.failure(error))
			} else {
				completion(.success(results?.statistics() ?? []))
			}
		}

		healthStore.execute(query)
	}

	func stepCount(startDate: Date, endDate: Date, options: HKQueryOptions) async throws -> [HKStatistics] {
		try await withCheckedThrowingContinuation { checkedContinuation in
			stepCount(startDate: startDate, endDate: endDate, options: options) { result in
				checkedContinuation.resume(with: result)
			}
		}
	}

	func todaysStepCount(options: HKQueryOptions) -> AnyPublisher<HKStatistics, Error> {
		Future { [weak self] promise in
			self?.todaysStepCount(options: options, completion: { result in
				switch result {
				case .failure(let error):
					promise(.failure(error))
				case .success(let statistic):
					promise(.success(statistic))
				}
			})
		}.eraseToAnyPublisher()
	}

	func todaysStepCount(options: HKQueryOptions, completion: @escaping AllieResultCompletion<HKStatistics>) {
		guard let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
			completion(.failure(HealthKitManagerError.invalidInput("Steps quantity type invalid")))
			return
		}

		let now = Date()
		let startOfDay = Calendar.current.startOfDay(for: now)
		let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: options)
		let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
			guard let statisticResult = result, error == nil else {
				completion(.failure(error ?? HealthKitManagerError.notAvailableOnDevice))
				return
			}
			completion(.success(statisticResult))
		}

		healthStore.execute(query)
	}

	func todaysStepCount(options: HKQueryOptions) async throws -> HKStatistics {
		try await withCheckedThrowingContinuation { checkedContinuation in
			todaysStepCount(options: options) { result in
				checkedContinuation.resume(with: result)
			}
		}
	}
}
