//
//  HealthKitManager.swift
//  alfred-ios
//

import Foundation
import UIKit
import HealthKit
import HealthKitUI

private enum HealthkitError: Error {
  case notAvailableOnDevice
  case dataTypeNotAvailable
}

class HealthKitManager {
    
    static let shared = HealthKitManager()
    
    func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Void) {
        
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, HealthkitError.notAvailableOnDevice)
            return
        }
        guard   let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass),
                let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate),
                let restingHeartRate = HKObjectType.quantityType(forIdentifier: .restingHeartRate),
                let bloodPressureDiastolic = HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic),
                let bloodPressureSystolic = HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic),
                let stepCount = HKObjectType.quantityType(forIdentifier: .stepCount)
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
    
    
    //otan patithei to modal tha ginei to request  - expand ta charts
    
    
    
    
    
    
}



