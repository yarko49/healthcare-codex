//
//  HealthKitManager.swift
//  Allie
//

import Foundation
import HealthKit
import HealthKitUI
import UIKit

private enum HealthkitError: Error {
	case notAvailableOnDevice
	case dataTypeNotAvailable
}

class HealthKitManager {
	static let shared = HealthKitManager()
	private let healthKitStore = HKHealthStore()

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
	func queryHealthData(initialUpload: Bool, for quantity: HealthKitDataType, from startDate: Date = Date.distantPast, to endDate: Date = Date(), completion: @escaping (Bool, [BundleEntry]) -> Void) {
		guard let sampleType = quantity.quantityType[0] else { return }
		let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)
		let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: !initialUpload)
		let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, results, _ in
			let quantitySamples = results?.compactMap { (sample) -> HKQuantitySample? in
				sample as? HKQuantitySample
			}.filter { (sample) -> Bool in
				!sample.ch_isUserEntered
			} ?? []

			let entries: [BundleEntry] = quantitySamples.compactMap { (data) -> BundleEntry? in
				let resource = CodexResource(id: nil, code: quantity.code, effectiveDateTime: DateFormatter.wholeDateRequest.string(from: data.startDate), identifier: nil, meta: nil, resourceType: "Observation", status: "final", subject: Subject(reference: DataContext.shared.userModel?.patientID ?? "", type: "Patient", identifier: nil, display: DataContext.shared.userModel?.displayName), valueQuantity: ValueQuantity(value: Int(data.quantity.doubleValue(for: quantity.unit)), unit: quantity.unit.unitString), birthDate: nil, gender: nil, name: nil, component: nil)
				let entry = BundleEntry(fullURL: nil, resource: resource, request: BundleRequest(method: "POST", url: "Observation"), search: nil, response: nil)
				return entry
			}
			completion(true, entries)
		}
		healthKitStore.execute(query)
	}

	func queryBloodPressure(initialUpload: Bool, from startDate: Date = Date.distantPast, to endDate: Date = Date(), completion: @escaping (Bool, [BundleEntry]) -> Void) {
		guard let bloodPressureDiastolic = HealthKitDataType.bloodPressure.quantityType[0], let bloodPressureSystolic = HealthKitDataType.bloodPressure.quantityType[1], let bloodPressure = HKQuantityType.correlationType(forIdentifier: .bloodPressure) else { return }
		let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)
		let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: !initialUpload)
		var entries: [BundleEntry] = []
		let query = HKSampleQuery(sampleType: bloodPressure, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, results, _ in
			if let dataList = results as? [HKCorrelation] {
				for data in dataList {
					if let dia = data.objects(for: bloodPressureDiastolic).first as? HKQuantitySample, let sys = data.objects(for: bloodPressureSystolic).first as? HKQuantitySample {
						let diaComponent = Component(code: MedicalCode.diastolicBloodPressure, valueQuantity: ValueQuantity(value: Int(dia.quantity.doubleValue(for: HKUnit.millimeterOfMercury())), unit: HKUnit.millimeterOfMercury().unitString))
						let sysComponent = Component(code: MedicalCode.systolicBloodPressure, valueQuantity: ValueQuantity(value: Int(sys.quantity.doubleValue(for: HKUnit.millimeterOfMercury())), unit: HKUnit.millimeterOfMercury().unitString))
						let resource = CodexResource(id: nil, code: MedicalCode.bloodPressure, effectiveDateTime: DateFormatter.wholeDateRequest.string(from: data.startDate), identifier: nil, meta: nil, resourceType: "Observation", status: "final", subject: Subject(reference: DataContext.shared.userModel?.patientID ?? "", type: "Patient", identifier: nil, display: DataContext.shared.userModel?.displayName), valueQuantity: nil, birthDate: nil, gender: nil, name: nil, component: [sysComponent, diaComponent])
						let entry = BundleEntry(fullURL: nil, resource: resource, request: BundleRequest(method: "POST", url: "Observation"), search: nil, response: nil)
						entries.append(entry)
					}
				}
			}
			completion(true, entries)
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

	func queryBloodGlucose(completion: @escaping (Result<[HKQuantitySample], Error>) -> Void) {
		guard let sampleType = HealthKitDataType.bloodGlucose.quantityType[0] else {
			return
		}
		let limit: Int = 0
		let predicate = HKQuery.predicateForSamples(withStart: Date(), end: Date(), options: [.strictStartDate])
		let endKey = HKSampleSortIdentifierEndDate
		let sortDescriptor = NSSortDescriptor(key: endKey, ascending: false)
		let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: limit, sortDescriptors: [sortDescriptor]) { _, samples, error in
			guard error == nil else {
				let theError = error ?? HealthkitError.dataTypeNotAvailable
				ALog.error("\(theError.localizedDescription)")
				completion(.failure(theError))
				return
			}
			let quantitySamples = samples?.compactMap { (sample) -> HKQuantitySample? in
				sample as? HKQuantitySample
			}
			let filtered = quantitySamples?.filter { (sample) -> Bool in
				!sample.ch_isUserEntered
			}
			completion(.success(filtered ?? []))
		}
		healthKitStore.execute(query)
	}
}
