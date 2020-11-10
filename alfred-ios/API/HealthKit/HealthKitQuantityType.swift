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
    
    var identifiers: [HKQuantityTypeIdentifier] {
        switch self {
        case .weight: return [.bodyMass]
        case .activity: return [.stepCount]
        case .bloodPressure: return [.bloodPressureDiastolic, .bloodPressureSystolic]
        case .heartRate: return [.heartRate]
        case .restingHR: return [.restingHeartRate]
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
    
    var hkUnit: HKUnit {
        switch self {
        case .activity: return .count()
        case .bloodPressure: return .millimeterOfMercury()
        case .heartRate: return HKUnit(from: "count/min")
        case .restingHR: return HKUnit(from: "count/min")
        case .weight: return .pound()
        }
    }
    
    func getStatus(for values: [Double]) -> (UIColor, String) {
        guard !values.isEmpty else { return (.clear, "") }
        switch self {
        case .weight:
            guard let weightValue = values.first else { return (.clear, "") }
            if weightValue < 110.0 {
                return (.statusRed, Str.belowNormal)
            } else if weightValue < 180 && weightValue >= 110 {
                return (.statusGreen, Str.healthy)
            } else if weightValue < 220 {
                return (.statusYellow, Str.heavy)
            } else {
                return (.statusRed, Str.obese)
            }
        case .activity:
            guard let stepCount = values.first else { return (.clear, "") }
            if stepCount < 500 {
                return (.statusRed, Str.belowNormal)
            } else if stepCount >= 500 && stepCount < 5000 {
                return (.statusYellow, Str.onTrack)
            }else {
                return (.statusGreen, Str.healthy)
            }
            
        case .bloodPressure:
        guard let systolic = values.first, let diastolic = values.last else { return (.clear, "") }
        if systolic < 120 && diastolic < 80 {
            return (.statusGreen, Str.normal)
        } else if 120...129 ~= systolic && diastolic < 80 {
            return (.statusYellow, Str.bpElevated)
        } else if 130...139 ~= systolic || 80...89 ~= diastolic {
            return (.statusOrange, Str.bpHigh)
        } else if 140...179 ~= systolic || diastolic >= 90 {
            return (.statusRed, Str.bpHigh2)
        } else if systolic >= 180 || diastolic > 12 {
            return (.statusDeepRed, Str.bpCrisis)
        } else {
            return (.clear, "")
        }
        case .restingHR:
            guard let restingHR = values.first else { return (.clear, "") }
            if restingHR < 30 || restingHR > 90 {
                return (.statusOrange, Str.notNormal)
            } else {
                return (.statusGreen, Str.healthy)
            }
        case .heartRate:
            guard let heartRate = values.first else { return (.clear, "") }
            if heartRate < 50 || heartRate > 110 {
                return (.statusOrange, Str.notNormal)
            } else {
                return (.statusGreen, Str.healthy)
            }
        }
        

    }
}

