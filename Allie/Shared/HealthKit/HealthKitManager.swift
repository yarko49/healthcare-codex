//
//  HealthKitManager.swift
//  Allie
//

import CareKit
import Combine
import Foundation
import HealthKit
import HealthKitUI
import ModelsR4
import UIKit

private enum HealthKitManagerError: Error {
	case notAvailableOnDevice
	case dataTypeNotAvailable
	case invalidInput(String)
}

class HealthKitManager {
	static let shared = HealthKitManager()
	private let healthKitStore = HKHealthStore()
	private var patientId: String? {
		CareManager.shared.patient?.profile.fhirId
	}

	private var cancellables: Set<AnyCancellable> = []

	typealias SampleCompletion = (Result<[HKSample], Error>) -> Void
	func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Void) {
		guard HKHealthStore.isHealthDataAvailable() else {
			completion(false, HealthKitManagerError.notAvailableOnDevice)
			return
		}
		guard let bodyMass = HealthKitDataType.bodyMass.quantityType[0],
		      let heartRate = HealthKitDataType.heartRate.quantityType[0],
		      let restingHeartRate = HealthKitDataType.restingHeartRate.quantityType[0],
		      let bloodPressureDiastolic = HealthKitDataType.bloodPressure.quantityType[0],
		      let bloodPressureSystolic = HealthKitDataType.bloodPressure.quantityType[1],
		      let stepCount = HealthKitDataType.stepCount.quantityType[0],
		      let bloodGloucose = HealthKitDataType.bloodGlucose.quantityType[0],
		      let insulinDelivery = HealthKitDataType.insulinDelivery.quantityType[0]
		else {
			completion(false, HealthKitManagerError.dataTypeNotAvailable)
			return
		}

		let healthKitTypesToWrite: Set<HKSampleType> = [insulinDelivery]
		let healthKitTypesToRead: Set<HKQuantityType> = [bodyMass, heartRate, restingHeartRate, bloodPressureDiastolic, bloodPressureSystolic, stepCount, bloodGloucose, insulinDelivery]
		healthKitStore.requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) { success, error in
			completion(success, error)
		}
	}

    func queryHealthData(dataType: HealthKitDataType, startDate: Date, endDate: Date, options: HKQueryOptions) -> AnyPublisher<[HKSample], Error> {
        if dataType == .bloodPressure {
            return queryBloodPressure(startDate: startDate, endDate: endDate, options: options)
        } else {
            guard let sampleType = dataType.quantityType[0] else {
                return Fail(error: HealthKitManagerError.invalidInput("DataType \(dataType.rawValue) missing sample type"))
                    .eraseToAnyPublisher()
            }
            return queryHealthData(quantityType: sampleType, startDate: startDate, endDate: endDate, options: options)
        }
    }

	func queryHealthData(dataType: HealthKitDataType, startDate: Date, endDate: Date, options: HKQueryOptions, completion: @escaping AllieResultCompletion<[HKSample]>) {
		if dataType == .bloodPressure {
			queryBloodPressure(startDate: startDate, endDate: endDate, options: options, completion: completion)
		} else {
			guard let sampleType = dataType.quantityType[0] else {
				completion(.failure(HealthKitManagerError.invalidInput("DataType \(dataType.rawValue) missing sample type")))
				return
			}
			queryHealthData(quantityType: sampleType, startDate: startDate, endDate: endDate, options: options, completion: completion)
		}
	}

    func queryHealthData(quantityType: HKQuantityType, startDate: Date, endDate: Date, options: HKQueryOptions) -> AnyPublisher<[HKSample], Error> {
        Future { [weak self] promise in
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: options)
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
            let query = HKSampleQuery(sampleType: quantityType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, results, error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(results ?? []))
                }
            }
            self?.healthKitStore.execute(query)
        }.eraseToAnyPublisher()
    }

	func queryHealthData(quantityType: HKQuantityType, startDate: Date, endDate: Date, options: HKQueryOptions, completion: @escaping AllieResultCompletion<[HKSample]>) {
		let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: options)
		let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
		let query = HKSampleQuery(sampleType: quantityType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, results, error in
			guard let samples = results, error == nil else {
				completion(.failure(error ?? HealthKitManagerError.dataTypeNotAvailable))
				return
			}
			completion(.success(samples))
		}
		healthKitStore.execute(query)
	}

	func queryStatisticsStepCount(startDate: Date, endDate: Date, options: HKQueryOptions) -> AnyPublisher<[HKStatistics], Error> {
		Future { [weak self] promise in
			let type = HKSampleType.quantityType(forIdentifier: .stepCount)
			let beginingOfDay = Calendar.current.startOfDay(for: startDate)
			var interval = DateComponents()
			interval.day = 1
			let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: options)
			let query = HKStatisticsCollectionQuery(quantityType: type!, quantitySamplePredicate: predicate, options: [.cumulativeSum, .separateBySource], anchorDate: beginingOfDay, intervalComponents: interval)
			query.initialResultsHandler = { _, results, error in
				if let error = error {
					promise(.failure(error))
				} else {
					let statistics = results?.statistics() ?? []
					promise(.success(statistics))
				}
			}

			self?.healthKitStore.execute(query)
		}.eraseToAnyPublisher()
	}

	func queryStatisticsStepCount(startDate: Date, endDate: Date, options: HKQueryOptions, completion: @escaping (Bool, [HKStatistics]) -> Void) {
		let type = HKSampleType.quantityType(forIdentifier: .stepCount)
		let beginingOfDay = Calendar.current.startOfDay(for: startDate)
		var interval = DateComponents()
		interval.day = 1
		let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: options)
		let query = HKStatisticsCollectionQuery(quantityType: type!, quantitySamplePredicate: predicate, options: [.cumulativeSum, .separateBySource], anchorDate: beginingOfDay, intervalComponents: interval)
		query.initialResultsHandler = { _, results, error in
			let statistics = results?.statistics() ?? []
			completion(error == nil, statistics)
		}

		healthKitStore.execute(query)
	}

	func queryBloodPressure(startDate: Date, endDate: Date, options: HKQueryOptions) -> AnyPublisher<[HKSample], Error> {
		guard let bloodPressure = HKQuantityType.correlationType(forIdentifier: .bloodPressure) else {
			return Fail(error: HealthKitManagerError.invalidInput("CorrelationType not valid BloodPressure"))
				.eraseToAnyPublisher()
		}
		return Future { [weak self] promise in
			let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: options)
			let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
			let query = HKSampleQuery(sampleType: bloodPressure, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, results, error in
				if let error = error {
					promise(.failure(error))
				} else {
					promise(.success(results ?? []))
				}
			}
			self?.healthKitStore.execute(query)
		}.eraseToAnyPublisher()
	}

	func queryBloodPressure(startDate: Date, endDate: Date, options: HKQueryOptions, completion: @escaping AllieResultCompletion<[HKSample]>) {
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
		healthKitStore.execute(query)
	}

	func queryMostRecentEntry(identifier: HKQuantityTypeIdentifier, options: HKQueryOptions) -> AnyPublisher<[HKSample], Error> {
		guard let type = HKSampleType.quantityType(forIdentifier: identifier) else {
			return Fail(error: HealthKitManagerError.invalidInput("SampleType notd valid \(identifier.rawValue)"))
				.eraseToAnyPublisher()
		}
		return Future { [weak self] promise in
			let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: [])
			let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
			let limit = 1
			let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: limit, sortDescriptors: [sortDescriptor]) { _, samples, error in
				if let error = error {
					promise(.failure(error))
				} else {
					promise(.success(samples ?? []))
				}
			}
			self?.healthKitStore.execute(query)
		}.eraseToAnyPublisher()
	}

	func queryMostRecentEntry(identifier: HKQuantityTypeIdentifier, options: HKQueryOptions, completion: @escaping AllieResultCompletion<HKSample>) {
		guard let type = HKSampleType.quantityType(forIdentifier: identifier) else {
			completion(.failure(HealthKitManagerError.invalidInput("SampleType notd valid \(identifier.rawValue)")))
			return
		}
		let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: [])
		let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
		let limit = 1
		let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: limit, sortDescriptors: [sortDescriptor]) { _, samples, error in
			guard let sample = samples?.first, error == nil else {
				completion(.failure(error ?? HealthKitManagerError.dataTypeNotAvailable))
				return
			}
			completion(.success(sample))
		}
		healthKitStore.execute(query)
	}

	func queryTodaySteps(options: HKQueryOptions) -> AnyPublisher<HKStatistics, Error> {
		guard let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
			return Fail(error: HealthKitManagerError.invalidInput("Steps quantity type invalid"))
				.eraseToAnyPublisher()
		}

		return Future { [weak self] promise in
			let now = Date()
			let startOfDay = Calendar.current.startOfDay(for: now)
			let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: options)
			let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
				if let error = error {
					promise(.failure(error))
				} else if let statisticResult = result {
					promise(.success(statisticResult))
				} else {
					promise(.failure(HealthKitManagerError.notAvailableOnDevice))
				}
			}

			self?.healthKitStore.execute(query)
		}.eraseToAnyPublisher()
	}

	func queryTodaySteps(options: HKQueryOptions, completion: @escaping AllieResultCompletion<HKStatistics>) {
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

		healthKitStore.execute(query)
	}

	func queryData(identifier: HKQuantityTypeIdentifier, startDate: Date, endDate: Date, intervalType: HealthStatsDateIntervalType, completion: @escaping (([StatsDataPoint]) -> Void)) {
		guard let type = HKObjectType.quantityType(forIdentifier: identifier) else {
			completion([])
			return
		}
		var interval = DateComponents()
		switch intervalType {
		case .daily: break
		case .weekly, .monthly: interval.day = 1
		case .yearly:
			if identifier == .stepCount {
				interval.day = 1
			} else {
				interval.month = 1
			}
		}

		var anchorComponents = Calendar.current.dateComponents([.day, .month, .year], from: startDate)
		anchorComponents.day = 1

		let anchorDate = Calendar.current.date(from: anchorComponents)!
		let options: HKStatisticsOptions = identifier == .stepCount ? .cumulativeSum : .discreteAverage
		let query = HKStatisticsCollectionQuery(quantityType: type, quantitySamplePredicate: nil, options: options, anchorDate: anchorDate, intervalComponents: interval)
		query.initialResultsHandler = { _, collection, _ in
			guard let collection = collection else {
				completion([])
				return
			}

			var data: [StatsDataPoint] = []
			collection.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
				let value = identifier == .stepCount ? statistics.sumQuantity() : statistics.averageQuantity()
				data.append(StatsDataPoint(date: statistics.startDate, value: value))
			}
			completion(data)
		}
		healthKitStore.execute(query)
	}

	func syncData(startDate: Date, endDate: Date, options: HKQueryOptions, completion: @escaping (Bool) -> Void) {
		searchHKData(startDate: startDate, endDate: endDate, callbackQueue: .main, options: options, completion: { [weak self] importSuccess, allEntries in
			if importSuccess, !allEntries.isEmpty {
				self?.uploadHKData(entries: allEntries, completion: completion)
			} else {
				completion(importSuccess)
			}
		})
	}

	func syncDataBackground(startDate: Date, endDate: Date, options: HKQueryOptions, completion: @escaping (Bool) -> Void) {
		searchHKData(startDate: startDate, endDate: endDate, callbackQueue: .main, options: options, completion: { [weak self] importSuccess, allEntries in
			if importSuccess, !allEntries.isEmpty {
				self?.uploadHKData(entries: allEntries, completion: completion)
			} else {
				completion(importSuccess)
			}
		})
	}

	func searchHKData(startDate: Date, endDate: Date, callbackQueue: DispatchQueue, options: HKQueryOptions, completion: @escaping (Bool, [ModelsR4.BundleEntry]) -> Void) {
		var samples: [HKSample] = []
		let importGroup = DispatchGroup()
		var errors: [Error] = []
		for quantity in HealthKitDataType.allCases {
			importGroup.enter()
			if quantity == .bloodPressure {
				queryBloodPressure(startDate: startDate, endDate: endDate, options: options, completion: { result in
					switch result {
					case .failure(let error):
						errors.append(error)
					case .success(let entries):
						samples.append(contentsOf: entries)
					}
					importGroup.leave()
				})
			} else {
				queryHealthData(dataType: quantity, startDate: startDate, endDate: endDate, options: options, completion: { result in
					switch result {
					case .failure(let error):
						errors.append(error)
					case .success(let entries):
						samples.append(contentsOf: entries)
					}
					importGroup.leave()
				})
			}
		}

		var entries: [ModelsR4.BundleEntry] = []
		if !samples.isEmpty {
			do {
				let observationFactory = try ObservationFactory()
				entries = try samples.compactMap { sample in
					let observation = try observationFactory.observation(from: sample)
					let subject = CareManager.shared.patient?.subject
					observation.subject = subject
					let route = APIRouter.postObservation(observation: observation)
					let observationPath = route.path
					let request = ModelsR4.BundleEntryRequest(method: FHIRPrimitive<HTTPVerb>(HTTPVerb.POST), url: FHIRPrimitive<FHIRURI>(stringLiteral: observationPath))
					let fullURL = FHIRPrimitive<FHIRURI>(stringLiteral: APIRouter.baseURLPath + observationPath)
					return ModelsR4.BundleEntry(extension: nil, fullUrl: fullURL, id: nil, link: nil, modifierExtension: nil, request: request, resource: .observation(observation), response: nil, search: nil)
				}
			} catch {
				ALog.error("\(error.localizedDescription)")
			}
		}
		importGroup.notify(queue: callbackQueue) {
			completion(errors.isEmpty, entries)
		}
	}

    func uploadHKData(entries: [ModelsR4.BundleEntry]) -> AnyPublisher<ModelsR4.Bundle, Error> {
        let bundle = ModelsR4.Bundle(entry: entries, type: FHIRPrimitive<BundleType>(.transaction))
        return APIClient.shared.post(bundle: bundle)
    }

	func uploadHKData(entries: [ModelsR4.BundleEntry], completion: @escaping (Bool) -> Void) {
		let bundle = ModelsR4.Bundle(entry: entries, type: FHIRPrimitive<BundleType>(.transaction))
		APIClient.shared.post(bundle: bundle)
			.sink(receiveCompletion: { result in
				if case .failure(let error) = result {
					ALog.error("Post Bundle", error: error)
					completion(false)
				}
			}, receiveValue: { _ in
				completion(true)
			}).store(in: &cancellables)
	}
}
