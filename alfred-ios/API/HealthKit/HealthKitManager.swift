//
//  HealthKitManager.swift
//  alfred-ios
//

import FHIR
import Foundation
import HealthKit
import HealthKitToFhir
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
	var numberOfData: Int = 0

	var stepsEntries: [Entry] = []
	var bpEntries: [Entry] = []
	var hrEntries: [Entry] = []
	var rhrEntries: [Entry] = []
	var weightEntries: [Entry] = []

	var stepsIds: [String] = []
	var bpIds: [String] = []
	var hrIds: [String] = []
	var rhrIds: [String] = []
	var weightIds: [String] = []

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
			// Background delivery
			//            if success {
			//                self.getHealthDataFromObserver(for: HealthKitDataType.allValues) { (success) in
			//                    if success {
			//                        print("YES")
			//                    } else {
			//                        print("NO")
			//                    }
			//                }
			//            }
			completion(success, error)
		}
	}

	func returnAllEntries() -> [Entry] {
		return stepsEntries + bpEntries + hrEntries + rhrEntries + weightEntries
	}

	func returnAllDataIds() -> [String] {
		return stepsIds + bpIds + hrIds + rhrIds + weightIds
	}

	func searchHKData(completion: @escaping (Bool) -> Void) {
		let importGroup = DispatchGroup()
		guard let date = Calendar.current.date(byAdding: .year, value: -1, to: Date()) else {
			completion(false)
			return
		}
		var results: [Bool] = []
		for quantity in HealthKitDataType.allValues {
			importGroup.enter()
			if quantity == .bloodPressure {
				getBloodPressure(from: date) { [weak self] success, ids in
					self?.bpIds = ids
					results.append(success)
					importGroup.leave()
				}
			} else {
				getHealthData(for: quantity, from: date) { [weak self] success, ids in
					switch quantity {
					case .bodyMass:
						self?.weightIds = ids
					case .heartRate:
						self?.hrIds = ids
					case .restingHeartRate:
						self?.rhrIds = ids
					case .stepCount:
						self?.stepsIds = ids
					case .bloodPressure:
						break
					}
					results.append(success)
					importGroup.leave()
				}
			}
		}
		importGroup.notify(queue: .main) {
			completion(results.allSatisfy { $0 })
		}
	}

	// Post Data from Health Kit to BE
	func getHealthData(for quantity: HealthKitDataType, from startDate: Date = Date.distantPast, to endDate: Date = Date(), completion: @escaping (Bool, [String]) -> Void) {
		guard let sampleType = quantity.type[0] else { return }
		let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)
		let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
		var ids: [String] = []
		let query = HKSampleQuery(sampleType: sampleType,
		                          predicate: predicate,
		                          limit: HKObjectQueryNoLimit,
		                          sortDescriptors: [sortDescriptor]) { _, results, _ in
			if let dataList = results {
				for data in dataList {
					if let sample = data as? HKQuantitySample {
						let resource = Resource(code: quantity.code, effectiveDateTime: DateFormatter.wholeDateRequest.string(from: data.startDate), id: nil, identifier: nil, meta: nil, resourceType: "Observation", status: "final", subject: Subject(reference: DataContext.shared.getPatientID(), type: "Patient", identifier: nil, display: DataContext.shared.getDisplayName()), valueQuantity: ValueQuantity(value: Int(sample.quantity.doubleValue(for: quantity.unit)), unit: quantity.unit.unitString), birthDate: nil, gender: nil, name: nil, component: nil)
						let entry = Entry(fullURL: nil, resource: resource, request: Request(method: "POST", url: "Observation"), search: nil, response: nil)
						switch quantity {
						case .bodyMass:
							self.weightEntries.append(entry)
						case .heartRate:
							self.hrEntries.append(entry)
						case .restingHeartRate:
							self.rhrEntries.append(entry)
						case .stepCount:
							self.stepsEntries.append(entry)
						case .bloodPressure:
							break
						}
						self.numberOfData += 1
						ids.append(sample.uuid.uuidString)
					}
				}
				completion(true, ids)
			}
		}
		HKHealthStore().execute(query)
	}

	func getBloodPressure(from startDate: Date = Date.distantPast, to endDate: Date = Date(), completion: @escaping (Bool, [String]) -> Void) {
		guard let bloodPressureDiastolic = HealthKitDataType.bloodPressure.type[0], let bloodPressureSystolic = HealthKitDataType.bloodPressure.type[1], let bloodPressure = HKQuantityType.correlationType(forIdentifier: .bloodPressure) else { return }

		let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)
		let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
		var ids: [String] = []
		let query = HKSampleQuery(sampleType: bloodPressure,
		                          predicate: predicate,
		                          limit: HKObjectQueryNoLimit,
		                          sortDescriptors: [sortDescriptor]) { _, results, _ in
			if let dataList = results as? [HKCorrelation] {
				for data in dataList {
					if let dia = data.objects(for: bloodPressureDiastolic).first as? HKQuantitySample,
					   let sys = data.objects(for: bloodPressureSystolic).first as? HKQuantitySample
					{
						let diaComponent = Component(code: DataContext.shared.diastolicBPCode, valueQuantity: ValueQuantity(value: Int(dia.quantity.doubleValue(for: HKUnit.millimeterOfMercury())), unit: HKUnit.millimeterOfMercury().unitString))
						let sysComponent = Component(code: DataContext.shared.systolicBPCode, valueQuantity: ValueQuantity(value: Int(sys.quantity.doubleValue(for: HKUnit.millimeterOfMercury())), unit: HKUnit.millimeterOfMercury().unitString))
						let resource = Resource(code: DataContext.shared.bpCode, effectiveDateTime: DateFormatter.wholeDateRequest.string(from: data.startDate), id: nil, identifier: nil, meta: nil, resourceType: "Observation", status: "final", subject: Subject(reference: DataContext.shared.getPatientID(), type: "Patient", identifier: nil, display: DataContext.shared.getDisplayName()), valueQuantity: nil, birthDate: nil, gender: nil, name: nil, component: [sysComponent, diaComponent])
						let entry = Entry(fullURL: nil, resource: resource, request: Request(method: "POST", url: "Observation"), search: nil, response: nil)
						self.bpEntries.append(entry)
						self.numberOfData += 1
						ids.append(dia.uuid.uuidString)
					}
				}
				completion(true, ids)
			}
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

	// Background delivery
	//    func getHealthDataFromObserver(for quantities: [HealthKitDataType], completion: @escaping (Bool)-> Void) {
	//        for quantity in quantities {
	//            guard let sampleType = quantity.type[0] else {return}
	//            HKHealthStore().enableBackgroundDelivery(for: sampleType, frequency: .immediate) { (success, error) in
	//                print(success)
	//            }
//
	//            let query = HKObserverQuery(sampleType: sampleType,
	//                                        predicate: nil) { [weak self] (query, completionHandler, error) in
	//                self?.getMostRecentData(for: quantity) { (success) in
	//                    if success {
	//                        completionHandler()
	//                    }
	//                }
//
	//            }
//
	//            HKHealthStore().execute(query)
	//        }
	//    }
//
	//    func getMostRecentData(for quantity: HealthKitDataType, completion: @escaping (Bool)-> Void) {
	//        guard let sampleType = quantity.type[0] else {return}
	//        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast,
	//                                                              end: Date(),
	//                                                              options: [])
	//        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate,
	//                                              ascending: false)
	//        let limit = 1
	//        let query = HKSampleQuery.init(sampleType: sampleType,
	//                                       predicate: predicate,
	//                                       limit: limit,
	//                                       sortDescriptors: [sortDescriptor]) { (query, results, error) in
	//            if let dataList = results {
	//                for data in dataList {
	//                    if let sample = data as? HKQuantitySample {
	//                        let resource = Resource(code: quantity.code, effectiveDateTime: DateFormatter.wholeDateRequest.string(from: data.startDate), id: nil, identifier: nil, meta: nil, resourceType: "Observation", status: "final", subject: Subject(reference: DataContext.shared.getPatientID(), type:"Patient", identifier: nil, display: DataContext.shared.getDisplayName()), valueQuantity: ValueQuantity(value: Int(sample.quantity.doubleValue(for: quantity.unit)), unit: quantity.unit.unitString), birthDate: nil, gender: nil, name: nil, component: nil)
	//                        let entry = Entry(fullURL: nil, resource: resource, request: Request(method: "POST", url: "Observation"), search: nil, response: nil)
	//                    }
	//                }
	//                completion(true)
	//            }
	//        }
	//        HKHealthStore().execute(query)
	//    }
}
