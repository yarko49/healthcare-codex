import CareKitStore
import Foundation

class ProfileHelper {
	static func computeHeight(value: Int) -> (Int, Int) {
		let feet = value / 100 != 0 ? value / 100 : value / 10
		let inches = value / 100 != 0 ? value % 100 : value % 10
		return (feet, inches)
	}

	static var firstName: String? {
		CareManager.shared.patient?.name.givenName
	}

	static var birthdate: Int? {
		guard let date = CareManager.shared.patient?.birthday else {
			return nil
		}
		return Calendar.current.component(.year, from: date)
	}

	static var gender: OCKBiologicalSex {
		CareManager.shared.patient?.sex ?? .female
	}

	static func getGoal(for type: HealthKitQuantityType) -> Int {
		switch type {
		case .weight:
			return UserDefaults.standard.measurementWeightInPoundsGoal
		case .bloodPressure:
			return UserDefaults.standard.measurementBloodPressureGoal
		case .activity:
			return UserDefaults.standard.measurementStepsGoal
		case .heartRate:
			return UserDefaults.standard.measurementHeartRateGoal
		case .restingHeartRate:
			return UserDefaults.standard.measurementRestingHeartRateGoal
		}
	}
}
