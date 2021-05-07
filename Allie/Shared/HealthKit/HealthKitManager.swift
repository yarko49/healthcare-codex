//
//  HealthKitManager.swift
//  Allie
//

import CareKit
import Foundation
import HealthKit
import HealthKitUI
import ModelsR4
import UIKit

private enum HealthkitError: Error {
	case notAvailableOnDevice
	case dataTypeNotAvailable
}

class HealthKitManager {
	static let shared = HealthKitManager()
	private let healthKitStore = HKHealthStore()
	private var patientId: String? {
		AppDelegate.careManager.patient?.profile.fhirId
	}

	func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Void) {
		guard HKHealthStore.isHealthDataAvailable() else {
			completion(false, HealthkitError.notAvailableOnDevice)
			return
		}
		guard let bodyMass = HealthKitDataType.bodyMass.quantityType[0],
		      let heartRate = HealthKitDataType.heartRate.quantityType[0],
		      let restingHeartRate = HealthKitDataType.restingHeartRate.quantityType[0],
		      let bloodPressureDiastolic = HealthKitDataType.bloodPressure.quantityType[0],
		      let bloodPressureSystolic = HealthKitDataType.bloodPressure.quantityType[1],
		      let stepCount = HealthKitDataType.stepCount.quantityType[0],
		      let bloodGloucose = HealthKitDataType.bloodGlucose.quantityType[0]
		else {
			completion(false, HealthkitError.dataTypeNotAvailable)
			return
		}

		let healthKitTypesToWrite: Set<HKSampleType> = []
		let healthKitTypesToRead: Set<HKQuantityType> = [bodyMass, heartRate, restingHeartRate, bloodPressureDiastolic, bloodPressureSystolic, stepCount, bloodGloucose]
		healthKitStore.requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) { success, error in
			completion(success, error)
		}
	}

	// Post Data from Health Kit to BE
	func queryHealthData(dataType: HealthKitDataType, startDate: Date, endDate: Date, completion: @escaping (Bool, [HKSample]) -> Void) {
		guard let sampleType = dataType.quantityType[0] else {
			return
		}
		queryHealthData(sampleType: sampleType, startDate: startDate, endDate: endDate, completion: completion)
	}

	func queryHealthData(sampleType: HKQuantityType, startDate: Date, endDate: Date, completion: @escaping (Bool, [HKSample]) -> Void) {
		let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)
		let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
		let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, results, _ in
			let samples = results ?? []
			completion(!samples.isEmpty, samples)
		}
		healthKitStore.execute(query)
	}

	func queryBloodPressure(startDate: Date, endDate: Date, completion: @escaping (Bool, [HKSample]) -> Void) {
		guard let bloodPressure = HKQuantityType.correlationType(forIdentifier: .bloodPressure) else {
			return
		}
		let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)
		let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
		let query = HKSampleQuery(sampleType: bloodPressure, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, results, _ in
			let samples = results ?? []
			completion(!samples.isEmpty, samples)
		}
		healthKitStore.execute(query)
	}

	func queryMostRecentEntry(identifier: HKQuantityTypeIdentifier, completion: @escaping (HKSample?) -> Void) {
		guard let type = HKSampleType.quantityType(forIdentifier: identifier) else {
			completion(nil)
			return
		}
		let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: [])
		let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
		let limit = 1
		let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: limit, sortDescriptors: [sortDescriptor]) { _, samples, _ in
			let sample = samples?.first
			DispatchQueue.main.async {
				completion(sample)
			}
		}
		healthKitStore.execute(query)
	}

	func queryTodaySteps(completion: @escaping (HKStatistics?) -> Void) {
		guard let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
			completion(nil)
			return
		}

		let now = Date()
		let startOfDay = Calendar.current.startOfDay(for: now)
		let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

		let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
			completion(result)
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

	func syncData(startDate: Date, endDate: Date, completion: @escaping (Bool) -> Void) {
		searchHKData(startDate: startDate, endDate: endDate, callbackQueue: .main, completion: { [weak self] importSuccess, allEntries in
			if importSuccess, !allEntries.isEmpty {
				self?.uploadHKData(entries: allEntries, completion: completion)
			} else {
				completion(importSuccess)
			}
		})
	}

	func syncDataBackground(startDate: Date, endDate: Date, completion: @escaping (Bool) -> Void) {
		searchHKData(startDate: startDate, endDate: endDate, callbackQueue: .main, completion: { [weak self] importSuccess, allEntries in
			if importSuccess, !allEntries.isEmpty {
				self?.uploadHKData(entries: allEntries, completion: completion)
			} else {
				completion(importSuccess)
			}
		})
	}

	func searchHKData(startDate: Date, endDate: Date, callbackQueue: DispatchQueue, completion: @escaping (Bool, [ModelsR4.BundleEntry]) -> Void) {
		var samples: [HKSample] = []
		let importGroup = DispatchGroup()
		var results: [Bool] = []
		for quantity in HealthKitDataType.allCases {
			importGroup.enter()
			if quantity == .bloodPressure {
				queryBloodPressure(startDate: startDate, endDate: endDate, completion: { success, entries in
					results.append(success)
					samples += entries
					importGroup.leave()
				})
			} else {
				queryHealthData(dataType: quantity, startDate: startDate, endDate: endDate, completion: { success, entries in
					results.append(success)
					samples += entries
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
					let subject = AppDelegate.careManager.patient?.subject
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
			completion(results.allSatisfy { $0 }, entries)
		}
	}

	func uploadHKData(entries: [ModelsR4.BundleEntry], completion: @escaping (Bool) -> Void) {
		let bundle = ModelsR4.Bundle(entry: entries, type: FHIRPrimitive<BundleType>(.transaction))
		APIClient.shared.post(bundle: bundle) { result in
			switch result {
			case .failure(let error):
				ALog.error("Post Bundle", error: error)
				completion(false)
			case .success:
				completion(true)
			}
		}
	}
}
