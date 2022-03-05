//
//  ProfileHelper.swift
//  Allie
//
//  Created by Waqar Malik on 12/17/20.
//

import CareKitStore
import CareModel
import CodexFoundation
import Foundation

class ProfileHelper {
	@Injected(\.careManager) static var careManager: CareManager

	static func computeHeight(value: Int) -> (Int, Int) {
		let feet = value / 100 != 0 ? value / 100 : value / 10
		let inches = value / 100 != 0 ? value % 100 : value % 10
		return (feet, inches)
	}

	static var firstName: String? {
		careManager.patient?.name.givenName
	}

	static var birthdate: Int? {
		guard let date = careManager.patient?.birthday else {
			return nil
		}
		return Calendar.current.component(.year, from: date)
	}

	static var gender: OCKBiologicalSex {
		careManager.patient?.sex ?? .female
	}

	static func getGoal(for type: HealthKitQuantityType) -> Int {
		switch type {
		case .weight:
			return 210
		case .bloodPressure:
			return 120
		case .activity:
			return 4000
		case .heartRate:
			return 80
		case .restingHeartRate:
			return 60
		case .bloodGlucose:
			return 98
		}
	}
}
