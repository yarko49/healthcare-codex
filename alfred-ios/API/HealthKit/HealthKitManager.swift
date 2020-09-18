//
//  HealthKitManager.swift
//  alfred-ios
//

import Foundation
import UIKit
import HealthKit
import HealthKitUI
import HealthKitToFhir

private enum HealthkitError: Error {
    case notAvailableOnDevice
    case dataTypeNotAvailable
}

enum HealthKitDataType: String {
    case bodyMass = "bodyMass"
    case heartRate = "heartRate"
    case restingHeartRate = "restingHeartRate"
    case stepCount = "stepCount"
    case bloodPressure = "bloodPressure"
    
}

class HealthKitManager {
    
    static let shared = HealthKitManager()
    
    let bodyMassSampleType = HKSampleType.quantityType(forIdentifier: .bodyMass)
    let heartRateSampleType = HKSampleType.quantityType(forIdentifier: .heartRate)
    let restingHeartRateSampleType = HKSampleType.quantityType(forIdentifier: .restingHeartRate)
    let stepCounSampleType = HKSampleType.quantityType(forIdentifier: .stepCount)
    
    let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass)
    let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate)
    let restingHeartRate = HKObjectType.quantityType(forIdentifier: .restingHeartRate)
    let stepCount = HKObjectType.quantityType(forIdentifier: .stepCount)
    let bloodPressureDiastolic = HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)
    let bloodPressureSystolic = HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)
    let bloodPressure = HKQuantityType.correlationType(forIdentifier: .bloodPressure)
    
    func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Void) {
        
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, HealthkitError.notAvailableOnDevice)
            return
        }
        guard   let bodyMass = bodyMass,
            let heartRate = heartRate,
            let restingHeartRate = restingHeartRate,
            let bloodPressureDiastolic = bloodPressureDiastolic,
            let bloodPressureSystolic = bloodPressureSystolic,
            let stepCount = stepCount
            else {
                
                completion(false, HealthkitError.dataTypeNotAvailable)
                return
        }
        
        let healthKitTypesToWrite: Set<HKSampleType> = []
        
        let healthKitTypesToRead: Set<HKObjectType> = [bodyMass, heartRate, restingHeartRate, bloodPressureDiastolic, bloodPressureSystolic, stepCount]
        
        HKHealthStore().requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) { (success, error) in
            completion(success, error)
        }
        
    }
    
    //TODO: This is test code, it's better to be reviewed later, when implemented in Charts for example.
    
    func getHealthData(for quantityType: HKQuantityType, from startDate: Date, to endDate: Date = Date() ) {
        
        let calendar = NSCalendar.current
        var anchorComponents = calendar.dateComponents([.minute, .hour, .day, .month, .year, .weekday, .timeZone], from: NSDate() as Date)
        
        anchorComponents.timeZone = .current
        anchorComponents.hour = 3
        
        guard let anchorDate = Calendar.current.date(from: anchorComponents) else {
            fatalError("*** unable to create a valid date from the given components ***")
        }
        
        var interval = DateComponents()
        interval.day = 1
        //interval.minute = 1
        
        var query: HKStatisticsCollectionQuery
        
        switch quantityType {
        case stepCount:
            query = HKStatisticsCollectionQuery(quantityType: quantityType,
                                                quantitySamplePredicate: nil,
                                                options: .cumulativeSum,
                                                anchorDate: anchorDate,
                                                intervalComponents: interval)
        case bodyMass:
            query = HKStatisticsCollectionQuery(quantityType: quantityType,
                                                quantitySamplePredicate: nil,
                                                options: .discreteMostRecent,
                                                anchorDate: anchorDate,
                                                intervalComponents: interval)
        case heartRate:
            query = HKStatisticsCollectionQuery(quantityType: quantityType,
                                                quantitySamplePredicate: nil,
                                                options: .discreteMostRecent,
                                                anchorDate: anchorDate,
                                                intervalComponents: interval)
        case restingHeartRate:
            query = HKStatisticsCollectionQuery(quantityType: quantityType,
                                                quantitySamplePredicate: nil,
                                                options: .discreteAverage,
                                                anchorDate: anchorDate,
                                                intervalComponents: interval)
            
        default:
            return
        }
        
        query.initialResultsHandler = {
            query, results, error in
            
            guard let statsCollection = results else {
                fatalError("*** An error occurred while calculating the statistics: \(String(describing: error?.localizedDescription)) ***")
                
            }
            
            statsCollection.enumerateStatistics(from: startDate, to: endDate) { statistics, stop in
                
                switch quantityType {
                case self.stepCount:
                    if let quantity = statistics.sumQuantity() {
                        let value = quantity.doubleValue(for: HKUnit.count())
                        let date = statistics.startDate
                        print(value)
                        print(date)
                    }
                case self.bodyMass:
                    if let quantity = statistics.mostRecentQuantity() {
                        let value = quantity.doubleValue(for: HKUnit.pound())
                        let date = statistics.startDate
                        print(value)
                        print(date)
                    }
                case self.heartRate:
                    if let quantity = statistics.mostRecentQuantity() {
                        let heartRateUnit = HKUnit(from: "count/min")
                        let value = quantity.doubleValue(for: heartRateUnit)
                        let date = statistics.startDate
                        print(value)
                        print(date)
                    }
                case self.restingHeartRate:
                    if let quantity = statistics.averageQuantity() {
                        let heartRateUnit = HKUnit(from: "count/min")
                        let value = quantity.doubleValue(for: heartRateUnit)
                        let date = statistics.startDate
                        print(value)
                        print(date)
                    }
                    
                default:
                    return
                }
                
            }
            
        }
        
        HKHealthStore().execute(query)
        
    }
    
    func getBloodPressure(from startDate: Date, to endDate: Date = Date() ) {
        
        guard let bloodPressureSystolic = HealthKitManager.shared.bloodPressureSystolic, let bloodPressureDiastolic = HealthKitManager.shared.bloodPressureDiastolic, let bloodPressure = HealthKitManager.shared.bloodPressure else { return }
        
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        
        let query = HKSampleQuery(sampleType: bloodPressure, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { (sampleQuery, results, error) in
            if let dataList = results as? [HKCorrelation] {
                for data in dataList
                {
                    do {
                        let  factory = try ObservationFactory()
                        do {
                            let observation = try factory.observation(from: data)
                            print(observation)
                            
                        } catch {
                            // Handle errors
                        }
                    } catch {
                        // Handle errors
                    }
                    
                    if let data1 = data.objects(for: bloodPressureSystolic).first as? HKQuantitySample,
                        let data2 = data.objects(for: bloodPressureDiastolic).first as? HKQuantitySample {
                        
                        let value1 = data1.quantity.doubleValue(for: HKUnit.millimeterOfMercury())
                        let value2 = data2.quantity.doubleValue(for: HKUnit.millimeterOfMercury())
                        
                        print("\(value1) / \(value2)    \(data.startDate)")
                    }
                }
            }
        }
        
        HKHealthStore().execute(query)
        
    }
    
    
        func getMostRecentSample(for sampleType: HKSampleType, startDate: Date, endDate: Date = Date(),
                                 completion: @escaping ([HKQuantitySample]?, Error?) -> Swift.Void) {
    
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
    
            let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
    
                DispatchQueue.main.async {
    
                    if let samples = samples as? [HKQuantitySample]?  {
                        completion(samples, nil)
                        return
                    }
                    completion(nil, error)
                }
            }
    
            HKHealthStore().execute(sampleQuery)
        }
    
//        func displaySample(for type: HKSampleType, samples: [HKQuantitySample]?) {
//
//            if let samples = samples {
//                for sample in samples {
//
//                    switch sampleType {
//                    case bodyMassSampleType:
//                        let weight = sample.quantity.doubleValue(for: HKUnit.pound())
//                        print("\(weight)  \(sample.startDate)\n\n")
//                    case heartRateSampleType:
//                        print("\(sample)  \(sample.startDate)\n\n")
//                    case restingHeartRateSampleType:
//                        print("\(sample)  \(sample.startDate)\n\n")
//                    case stepCounSampleType:
//                        print("\(sample)  \(sample.startDate)\n\n")
//                    default:
//                        break
//                    }
//                }
//
//            }
//        }
    
    
    
    
    //MARK: - Average values
    
    
    func getSSAverageHighLowValues(for quantityType: HKQuantityType, from startDate: Date, to endDate: Date, completion: @escaping (Double?, Double?, Double?) -> Void) {
        
        let discreteQuery = HKStatisticsQuery(quantityType: quantityType,
                                              quantitySamplePredicate: nil,
                                              options: [.cumulativeSum]) {
                                                    query, statistics, error in
                                          
                                                
                                                print(statistics)
                                                
                                                   
                                                
        } 
        
        
        HKHealthStore().execute(discreteQuery)
        
    }
    
    
    
    func getAverageHighLowValues(for quantityType: HKQuantityType?, from startDate: Date, to endDate: Date, completion: @escaping (Double?, Double?, Double?) -> Void) {
        
        let calendar = NSCalendar.current
        var anchorComponents = calendar.dateComponents([.minute, .hour, .day, .month, .year, .weekday, .timeZone], from: NSDate() as Date)
        
        anchorComponents.timeZone = .current
        anchorComponents.hour = 3
        
        guard let anchorDate = Calendar.current.date(from: anchorComponents) else {
            fatalError("*** unable to create a valid date from the given components ***")
        }
        
        var interval = DateComponents()
        interval.day = 1
        //interval.minute = 1
        
        var query: HKStatisticsCollectionQuery
        
        switch quantityType {
        case bloodPressureSystolic:
            query = HKStatisticsCollectionQuery(quantityType: quantityType!,
                                                quantitySamplePredicate: nil,
                                                options: [.discreteAverage, .discreteMax, .discreteMin],
                                                anchorDate: anchorDate,
                                                intervalComponents: interval)
        default:
            completion(nil,nil,nil)
            return
        }
        
        query.initialResultsHandler = { query, results, error in
            
            guard let statsCollection = results else {
                fatalError("*** An error occurred while calculating the statistics: \(String(describing: error?.localizedDescription)) ***")
            }
            
            var avg: Double? = nil
            var max: Double? = nil
            var min: Double? = nil

            statsCollection.enumerateStatistics(from: startDate, to: endDate) { statistics, stop in
                switch quantityType {
                case self.bloodPressureSystolic:
                    guard let avgQuantity = statistics.averageQuantity()?.doubleValue(for: HKUnit(from: "mmHg")),
                        let maxQuantity = statistics.maximumQuantity()?.doubleValue(for: HKUnit(from: "mmHg")),
                        let minQuantity = statistics.minimumQuantity()?.doubleValue(for: HKUnit(from: "mmHg")) else {
                        break
                    }
                    avg = avgQuantity
                    max = maxQuantity
                    min = minQuantity
                    print("Average value: ", avg, " mmHg")
                    print("High value: ", max, " mmHg")
                    print("Low value: ", min, " mmHg")
                    
                default:
                    return
                }
            }
            
            completion(avg, max, min)
            return
        }
        
        HKHealthStore().execute(query)
    }
    
    //MARK: - Total values
    
    func getBloodPressure(from startDate: Date, to endDate: Date, completion: @escaping ([HKCorrelation]) -> Void) {
        guard let bloodPressure = HealthKitManager.shared.bloodPressure else { return }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        
        let query = HKSampleQuery(sampleType: bloodPressure, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { (sampleQuery, results, error) in
            completion(results as? [HKCorrelation] ?? [])
            return
        }
        HKHealthStore().execute(query)
    }
    
    
}

