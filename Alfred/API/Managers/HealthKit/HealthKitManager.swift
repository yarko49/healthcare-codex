//
//  HealthKitManager.swift
//  alfred-ios
//

import Foundation
import HealthKit
import HealthKitUI
import UIKit

private enum HealthkitError: Error {
	case notAvailableOnDevice
	case dataTypeNotAvailable
}

enum HealthKitDataType: CustomStringConvertible {
	case bodyMass
	case heartRate
	case restingHeartRate
	case stepCount
	case bloodPressure

	var description: String {
		switch self {
		case .bodyMass:
			return "bodyMass"
		case .heartRate:
			return "heartRate"
		case .restingHeartRate:
			return "restingHeartRate"
		case .stepCount:
			return "stepCount"
		case .bloodPressure:
			return "bloodPressure"
		}
	}

	var unit: HKUnit {
		switch self {
		case .bodyMass:
			return HKUnit.pound()
		case .heartRate:
			return HKUnit(from: "count/min")
		case .restingHeartRate:
			return HKUnit(from: "count/min")
		case .stepCount:
			return HKUnit.count()
		case .bloodPressure:
			return HKUnit.millimeterOfMercury()
		}
	}

	var code: Code {
		switch self {
		case .bodyMass:
			return DataContext.shared.weightCode
		case .heartRate:
			return DataContext.shared.hrCode
		case .restingHeartRate:
			return DataContext.shared.restingHRCode
		case .stepCount:
			return DataContext.shared.stepsCode
		case .bloodPressure:
			return DataContext.shared.bpCode
		}
	}

	var type: [HKQuantityType?] {
		switch self {
		case .bodyMass:
			return [HKObjectType.quantityType(forIdentifier: .bodyMass)]
		case .heartRate:
			return [HKObjectType.quantityType(forIdentifier: .heartRate)]
		case .restingHeartRate:
			return [HKObjectType.quantityType(forIdentifier: .restingHeartRate)]
		case .stepCount:
			return [HKObjectType.quantityType(forIdentifier: .stepCount)]
		case .bloodPressure:
			return [HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic), HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)]
		}
	}

	static let allValues = [bodyMass, heartRate, restingHeartRate, stepCount, bloodPressure]
}

class HealthKitManager {
	static let shared = HealthKitManager()

	func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Void) {
		guard HKHealthStore.isHealthDataAvailable() else {
			completion(false, HealthkitError.notAvailableOnDevice)
			return
		}
		guard let bodyMass = HealthKitDataType.bodyMass.type[0],
		      let heartRate = HealthKitDataType.heartRate.type[0],
		      let restingHeartRate = HealthKitDataType.restingHeartRate.type[0],
		      let bloodPressureDiastolic = HealthKitDataType.bloodPressure.type[0],
		      let bloodPressureSystolic = HealthKitDataType.bloodPressure.type[1],
		      let stepCount = HealthKitDataType.stepCount.type[0]
		else {
			completion(false, HealthkitError.dataTypeNotAvailable)
			return
		}

		let healthKitTypesToWrite: Set<HKSampleType> = []

		let healthKitTypesToRead: Set<HKQuantityType> = [bodyMass, heartRate, restingHeartRate, bloodPressureDiastolic, bloodPressureSystolic, stepCount]

		HKHealthStore().requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) { success, error in
			completion(success, error)
		}
	}

	// Post Data from Health Kit to BE
	func getHealthData(initialUpload: Bool, for quantity: HealthKitDataType, from startDate: Date = Date.distantPast, to endDate: Date = Date(), completion: @escaping (Bool, [Entry]) -> Void) {
		guard let sampleType = quantity.type[0] else { return }
		let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)
		let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: !initialUpload)
		var entries: [Entry] = []
		let query = HKSampleQuery(sampleType: sampleType,
		                          predicate: predicate,
		                          limit: HKObjectQueryNoLimit,
		                          sortDescriptors: [sortDescriptor]) { _, results, _ in
			if let dataList = results {
				for data in dataList {
					if let sample = data as? HKQuantitySample {
						let resource = Resource(code: quantity.code, effectiveDateTime: DateFormatter.wholeDateRequest.string(from: data.startDate), id: nil, identifier: nil, meta: nil, resourceType: "Observation", status: "final", subject: Subject(reference: DataContext.shared.patientID, type: "Patient", identifier: nil, display: DataContext.shared.displayName), valueQuantity: ValueQuantity(value: Int(sample.quantity.doubleValue(for: quantity.unit)), unit: quantity.unit.unitString), birthDate: nil, gender: nil, name: nil, component: nil)
						let entry = Entry(fullURL: nil, resource: resource, request: BERequest(method: "POST", url: "Observation"), search: nil, response: nil)
						entries.append(entry)
					}
				}
			}
			completion(true, entries)
		}
		HKHealthStore().execute(query)
	}

	func getBloodPressure(initialUpload: Bool, from startDate: Date = Date.distantPast, to endDate: Date = Date(), completion: @escaping (Bool, [Entry]) -> Void) {
		guard let bloodPressureDiastolic = HealthKitDataType.bloodPressure.type[0], let bloodPressureSystolic = HealthKitDataType.bloodPressure.type[1], let bloodPressure = HKQuantityType.correlationType(forIdentifier: .bloodPressure) else { return }

		let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)
		let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: !initialUpload)
		var entries: [Entry] = []
		let query = HKSampleQuery(sampleType: bloodPressure,
		                          predicate: predicate,
		                          limit: HKObjectQueryNoLimit,
		                          sortDescriptors: [sortDescriptor]) { _, results, _ in
			if let dataList = results as? [HKCorrelation] {
				for data in dataList {
					if let dia = data.objects(for: bloodPressureDiastolic).first as? HKQuantitySample, let sys = data.objects(for: bloodPressureSystolic).first as? HKQuantitySample {
						let diaComponent = Component(code: DataContext.shared.diastolicBPCode, valueQuantity: ValueQuantity(value: Int(dia.quantity.doubleValue(for: HKUnit.millimeterOfMercury())), unit: HKUnit.millimeterOfMercury().unitString))
						let sysComponent = Component(code: DataContext.shared.systolicBPCode, valueQuantity: ValueQuantity(value: Int(sys.quantity.doubleValue(for: HKUnit.millimeterOfMercury())), unit: HKUnit.millimeterOfMercury().unitString))
						let resource = Resource(code: DataContext.shared.bpCode, effectiveDateTime: DateFormatter.wholeDateRequest.string(from: data.startDate), id: nil, identifier: nil, meta: nil, resourceType: "Observation", status: "final", subject: Subject(reference: DataContext.shared.patientID, type: "Patient", identifier: nil, display: DataContext.shared.displayName), valueQuantity: nil, birthDate: nil, gender: nil, name: nil, component: [sysComponent, diaComponent])
						let entry = Entry(fullURL: nil, resource: resource, request: BERequest(method: "POST", url: "Observation"), search: nil, response: nil)
						entries.append(entry)
					}
				}
			}
			completion(true, entries)
		}
		HKHealthStore().execute(query)
	}

	func getMostRecentEntry(identifier: HKQuantityTypeIdentifier, completion: @escaping (HKSample?) -> Void) {
		guard let type = HKSampleType.quantityType(forIdentifier: identifier) else {
			completion(nil)
			return
		}
		print(type)
		let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast,
		                                            end: Date(),
		                                            options: [])
		let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate,
		                                      ascending: false)
		let limit = 1
		let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: limit, sortDescriptors: [sortDescriptor]) { _, samples, _ in
			let sample = samples?.first
			DispatchQueue.main.async {
				completion(sample)
			}
		}
		HKHealthStore().execute(query)
	}

	func getTodaySteps(completion: @escaping (HKStatistics?) -> Void) {
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

		HKHealthStore().execute(query)
	}

	func getData(identifier: HKQuantityTypeIdentifier, startDate: Date, endDate: Date, intervalType: HealthStatsDateIntervalType, completion: @escaping (([StatsDataPoint]) -> Void)) {
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
		let query = HKStatisticsCollectionQuery(quantityType: type,
		                                        quantitySamplePredicate: nil,
		                                        options: options,
		                                        anchorDate: anchorDate,
		                                        intervalComponents: interval)
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
		HKHealthStore().execute(query)
	}
}
