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

	var healthKitAuthorized: Bool {
		guard let bodyMass = HealthKitDataType.bodyMass.quantityType[0],
		      let heartRate = HealthKitDataType.heartRate.quantityType[0],
		      let restingHeartRate = HealthKitDataType.restingHeartRate.quantityType[0],
		      let bloodPressureDiastolic = HealthKitDataType.bloodPressure.quantityType[0],
		      let bloodPressureSystolic = HealthKitDataType.bloodPressure.quantityType[1],
		      let stepCount = HealthKitDataType.stepCount.quantityType[0],
		      let bloodGloucose = HealthKitDataType.bloodGlucose.quantityType[0]
		else {
			return false
		}
		let quantityTypes = [heartRate, restingHeartRate, bloodPressureSystolic, bloodPressureDiastolic, stepCount, bloodGloucose]
		var result: HKAuthorizationStatus = healthKitStore.authorizationStatus(for: bodyMass)
		for item in quantityTypes {
			if result == .sharingDenied || result == .notDetermined {
				break
			}
			result = healthKitStore.authorizationStatus(for: item)
		}
		return result == .sharingAuthorized
	}

	// Post Data from Health Kit to BE
	func queryHealthData(initialUpload: Bool, for quantity: HealthKitDataType, from startDate: Date = Date.distantPast, to endDate: Date = Date(), completion: @escaping (Bool, [HKSample]) -> Void) {
		guard let sampleType = quantity.quantityType[0] else {
			return
		}

		let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)
		let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: !initialUpload)
		let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, results, _ in
			let samples = results ?? []
			completion(!samples.isEmpty, samples)
		}
		healthKitStore.execute(query)
	}

	func queryBloodPressure(initialUpload: Bool, from startDate: Date = Date.distantPast, to endDate: Date = Date(), completion: @escaping (Bool, [HKSample]) -> Void) {
		guard let bloodPressure = HKQuantityType.correlationType(forIdentifier: .bloodPressure) else {
			return
		}
		let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)
		let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: !initialUpload)
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
}
