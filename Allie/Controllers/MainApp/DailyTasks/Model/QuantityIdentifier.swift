//
//  QuantityIdentifier.swift
//  Allie
//
//  Created by Waqar Malik on 1/15/21.
//

import Foundation
import HealthKit

enum QuantityIdentifier: String, Codable, CaseIterable {
	case bloodPressure
	case bloodPressureDiastolic
	case bloodPressureSystolic
	case bloodGlucose
	case bodyFatPercentage
	case bodyMass
	case bodyMassIndex
	case bodyTemperature
	case environmentalAudioExposure
	case headphoneAudioExposure
	case heartRate
	case height
	case leanBodyMass
	case oxygenSaturation
	case respiratoryRate
	case restingHeartRate
	case steps
	case vo2Max
	case walkingHeartRateAverage
}

extension QuantityIdentifier {
	var hkQuantityIdentifier: HKQuantityTypeIdentifier {
		switch self {
		case .bloodPressure:
			return .bloodPressureSystolic
		case .bloodPressureDiastolic:
			return .bloodPressureDiastolic
		case .bloodPressureSystolic:
			return .bloodPressureSystolic
		case .bloodGlucose:
			return .bloodGlucose
		case .bodyFatPercentage:
			return .bodyFatPercentage
		case .bodyMass:
			return .bodyMass
		case .bodyMassIndex:
			return .bodyMassIndex
		case .bodyTemperature:
			return .bodyTemperature
		case .environmentalAudioExposure:
			return .environmentalAudioExposure
		case .headphoneAudioExposure:
			return .headphoneAudioExposure
		case .heartRate:
			return .heartRate
		case .height:
			return .height
		case .leanBodyMass:
			return .leanBodyMass
		case .oxygenSaturation:
			return .oxygenSaturation
		case .respiratoryRate:
			return .respiratoryRate
		case .restingHeartRate:
			return .restingHeartRate
		case .steps:
			return .stepCount
		case .vo2Max:
			return .vo2Max
		case .walkingHeartRateAverage:
			return .walkingHeartRateAverage
		}
	}
}
