//
//  HealthKitQuantityType.swift
//  alfred-ios
//

import UIKit
import HealthKit

enum HealthKitQuantityType: String, CaseIterable {
    
    case weight = "Weight"
    case activity = "Activity"
    case bloodPressure = "Blood Pressure"
    case restingHR = "Resting Hearth Rate"
    case heartRate  = "Heart Rate"
    
    func getHKitQuantityType() -> HKQuantityType? {
        switch self {
        case .activity:
            return HKObjectType.quantityType(forIdentifier: .stepCount)
        case .weight:
            return HKObjectType.quantityType(forIdentifier: .bodyMass)
        case .restingHR:
            return HKObjectType.quantityType(forIdentifier: .restingHeartRate)
        case .heartRate:
            return HKObjectType.quantityType(forIdentifier: .heartRate)
        default:
            return nil
        }
    }
    
    func getColor() -> UIColor {
        switch self {
        case .activity:
            return UIColor.activityBG
        case .bloodPressure:
            return UIColor.bloodPressureColor ?? .red
        case .heartRate:
            return UIColor.heartRateColor ?? .systemPink
        case .restingHR:
            return UIColor.restingHR ?? .systemPink
        case .weight:
            return UIColor.weightBG
        }
    }
    
    func getImage() -> UIImage {
        switch self {
        case .activity:
            return UIImage(named: "activityIcon") ?? UIImage()
        case .bloodPressure:
            return UIImage(named: "bloodPressureIcon") ?? UIImage()
        case .heartRate:
            return UIImage(named: "heartRateIcon") ?? UIImage()
        case .restingHR:
            return UIImage(named: "restingHRIcon") ?? UIImage()
        case .weight:
            return UIImage(named: "weightIcon") ?? UIImage()
        }
    }
    
    func getUnit() -> String {
        switch self {
        case .activity:
            return "steps"
        case .bloodPressure:
            return "mmHG"
        case .heartRate:
            return "bpm"
        case .restingHR:
            return "bpm"
        case .weight:
            return "lbs"
        }
    }
    
}
