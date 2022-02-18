//
//  HealthKitManager.swift
//  Allie
//

import CareKit
import CodexFoundation
import Combine
import Foundation
import HealthKit
import HealthKitUI
import HKToFHIR
import ModelsR4
import UIKit

private struct HealthKitManagerKey: InjectionKey {
	static var currentValue = HealthKitManager()
}

extension InjectedValues {
	var healthKitManager: HealthKitManager {
		get { Self[HealthKitManagerKey.self] }
		set { Self[HealthKitManagerKey.self] = newValue }
	}
}

enum HealthKitManagerError: Error {
	case notAvailableOnDevice
	case dataTypeNotAvailable
	case invalidInput(String)
}

class HealthKitManager {
	let healthStore = HKHealthStore()
	private var patientId: String? {
		careManager.patient?.profile.fhirId
	}

	@Injected(\.careManager) var careManager: CareManager
	@Injected(\.networkAPI) var networkAPI: AllieAPI
	private var cancellables: Set<AnyCancellable> = []
	var sequenceNumbers = BGMSequenceNumbers<Int>()

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

		let healthKitTypesToWrite: Set<HKSampleType> = [bodyMass, heartRate, bloodPressureSystolic, bloodPressureDiastolic, bloodGloucose, insulinDelivery]
		let healthKitTypesToRead: Set<HKQuantityType> = [bodyMass, heartRate, restingHeartRate, bloodPressureDiastolic, bloodPressureSystolic, stepCount, bloodGloucose, insulinDelivery]
		healthStore.requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) { [weak self] success, error in
			if success {
				DispatchQueue.global(qos: .background).async {
					self?.sequenceNumbers.removeAll()
					self?.fetchAllSequenceNumbers { newValues in
						self?.sequenceNumbers.formUnion(newValues)
					}
				}
			}
			completion(success, error)
		}
	}

	func authorizeHealthKit() async throws -> Bool {
		try await withCheckedThrowingContinuation { checkedContinuation in
			authorizeHealthKit { result, error in
				if let error = error {
					checkedContinuation.resume(throwing: error)
				} else {
					checkedContinuation.resume(returning: result)
				}
			}
		}
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
		healthStore.execute(query)
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
				bloodPressure(startDate: startDate, endDate: endDate, options: options, completion: { result in
					switch result {
					case .failure(let error):
						errors.append(error)
					case .success(let entries):
						samples.append(contentsOf: entries)
					}
					importGroup.leave()
				})
			} else {
				sample(dataType: quantity, startDate: startDate, endDate: endDate, options: options, completion: { result in
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
					let subject = careManager.patient?.subject
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
		return networkAPI.post(bundle: bundle)
	}

	func uploadHKData(entries: [ModelsR4.BundleEntry], completion: @escaping (Bool) -> Void) {
		let bundle = ModelsR4.Bundle(entry: entries, type: FHIRPrimitive<BundleType>(.transaction))
		networkAPI.post(bundle: bundle)
			.sink(receiveCompletion: { result in
				if case .failure(let error) = result {
					ALog.error("Post Bundle", error: error)
					completion(false)
				}
			}, receiveValue: { _ in
				completion(true)
			}).store(in: &cancellables)
	}

	func fetch(uuid: UUID, quantityIdentifier: String, completion: AllieResultCompletion<HKSample>?) {
		let predicate = HKQuery.predicateForObject(with: uuid)
		let identifier = HKQuantityTypeIdentifier(rawValue: quantityIdentifier)
		guard let sampleType = HKSampleType.quantityType(forIdentifier: identifier) else {
			completion?(.failure(HealthKitManagerError.invalidInput("Invalid quantityIdentifier \(quantityIdentifier)")))
			return
		}

		let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: 1, sortDescriptors: nil) { _, samples, error in
			if let error = error {
				completion?(.failure(error))
			} else if let sample = samples?.first {
				completion?(.success(sample))
			} else {
				completion?(.failure(HealthKitManagerError.notAvailableOnDevice))
			}
		}
		healthStore.execute(sampleQuery)
	}

	func delete(uuid: UUID, quantityIdentifier: String, completion: AllieResultCompletion<HKSample>?) {
		fetch(uuid: uuid, quantityIdentifier: quantityIdentifier) { [weak self] result in
			switch result {
			case .failure(let error):
				completion?(.failure(error))
			case .success(let sample):
				self?.delete(sample: sample, completion: completion)
			}
		}
	}

	func fetchCorrelationSample(uuid: UUID, sampleType: HKCorrelationType, completion: AllieResultCompletion<HKSample>?) {
		let predicate = HKCorrelationQuery.predicateForObject(with: uuid)
		let query = HKCorrelationQuery(type: sampleType, predicate: predicate, samplePredicates: [:]) { _, results, error in
			if let error = error {
				completion?(.failure(error))
			} else if let sample = results?.first {
				completion?(.success(sample))
			} else {
				completion?(.failure(HealthKitManagerError.notAvailableOnDevice))
			}
		}
		healthStore.execute(query)
	}

	func deleteCorrelationSample(uuid: UUID, sampleType: HKCorrelationType, completion: AllieResultCompletion<HKSample>?) {
		fetchCorrelationSample(uuid: uuid, sampleType: sampleType, completion: { [weak self] result in
			switch result {
			case .failure(let error):
				completion?(.failure(error))
			case .success(let sample):
				self?.delete(sample: sample, completion: completion)
			}
		})
	}

	func delete(sample: HKSample, completion: AllieResultCompletion<HKSample>?) {
		healthStore.delete(sample) { success, error in
			if let error = error {
				completion?(.failure(error))
			} else if success {
				NotificationCenter.default.post(name: .didModifyHealthKitStore, object: nil)
				completion?(.success(sample))
			} else {
				completion?(.failure(HealthKitManagerError.notAvailableOnDevice))
			}
		}
	}

	func save(sample: HKSample, completion: @escaping AllieResultCompletion<HKSample>) {
		healthStore.save(sample) { success, error in
			if let error = error {
				completion(.failure(error))
			} else if success == false {
				completion(.failure(AllieError.forbidden("Unable to save sample")))
			} else {
				NotificationCenter.default.post(name: .didModifyHealthKitStore, object: nil)
				completion(.success(sample))
			}
		}
	}

	func save(samples: [HKSample], completion: @escaping AllieResultCompletion<[HKSample]>) {
		healthStore.save(samples) { success, error in
			if let error = error {
				completion(.failure(error))
			} else if success == false {
				completion(.failure(AllieError.forbidden("Unable to save sample")))
			} else {
				NotificationCenter.default.post(name: .didModifyHealthKitStore, object: nil)
				completion(.success(samples))
			}
		}
	}

	func fetch(uuid: UUID, quantityIdentifier: String) async throws -> HKSample {
		let predicate = HKQuery.predicateForObject(with: uuid)
		let identifier = HKQuantityTypeIdentifier(rawValue: quantityIdentifier)
		guard let sampleType = HKSampleType.quantityType(forIdentifier: identifier) else {
			throw HealthKitManagerError.invalidInput("Invalid quantityIdentifier \(quantityIdentifier)")
		}

		return try await withCheckedThrowingContinuation { checkedContinuation in
			let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: 1, sortDescriptors: nil) { _, samples, error in
				if let error = error {
					checkedContinuation.resume(throwing: error)
				} else if let sample = samples?.first {
					checkedContinuation.resume(returning: sample)
				} else {
					checkedContinuation.resume(throwing: HealthKitManagerError.notAvailableOnDevice)
				}
			}
			healthStore.execute(sampleQuery)
		}
	}

	func delete(uuid: UUID, quantityIdentifier: String) async throws -> HKSample {
		let sample = try await fetch(uuid: uuid, quantityIdentifier: quantityIdentifier)
		return try await delete(sample: sample)
	}

	func delete(sample: HKSample) async throws -> HKSample {
		try await withCheckedThrowingContinuation { checkedContinuation in
			healthStore.delete(sample) { success, error in
				if let error = error {
					checkedContinuation.resume(throwing: error)
				} else if success {
					NotificationCenter.default.post(name: .didModifyHealthKitStore, object: nil)
					checkedContinuation.resume(returning: sample)
				} else {
					checkedContinuation.resume(throwing: HealthKitManagerError.notAvailableOnDevice)
				}
			}
		}
	}

	func save(samples: [HKSample]) async throws -> [HKSample] {
		try await withCheckedThrowingContinuation { checkedContinuation in
			healthStore.save(samples) { didSave, error in
				if let error = error {
					checkedContinuation.resume(throwing: error)
				} else if didSave == false {
					checkedContinuation.resume(throwing: AllieError.forbidden("Unable to save sample"))
				} else {
					NotificationCenter.default.post(name: .didModifyHealthKitStore, object: nil)
					checkedContinuation.resume(returning: samples)
				}
			}
		}
	}

	func save(sample: HKSample) async throws -> HKSample {
		let samples = try await save(samples: [sample])
		guard let first = samples.first else {
			throw AllieError.missing("Unable to save sample")
		}

		return first
	}

	func fetchCorrelationSample(uuid: UUID, sampleType: HKCorrelationType) async throws -> HKSample {
		try await withCheckedThrowingContinuation { checkedContinuation in
			let predicate = HKCorrelationQuery.predicateForObject(with: uuid)
			let query = HKCorrelationQuery(type: sampleType, predicate: predicate, samplePredicates: [:]) { _, results, error in
				if let error = error {
					checkedContinuation.resume(throwing: error)
				} else if let sample = results?.first {
					checkedContinuation.resume(returning: sample)
				} else {
					checkedContinuation.resume(throwing: HealthKitManagerError.notAvailableOnDevice)
				}
			}
			healthStore.execute(query)
		}
	}

	func deleteCorrelationSample(uuid: UUID, sampleType: HKCorrelationType) async throws -> HKSample {
		let sample = try await fetchCorrelationSample(uuid: uuid, sampleType: sampleType)
		return try await delete(sample: sample)
	}
}
