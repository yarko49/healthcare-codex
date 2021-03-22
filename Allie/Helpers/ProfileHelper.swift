import CareKitStore
import Foundation

class ProfileHelper {
	static func computeHeight(value: Int) -> (Int, Int) {
		let feet = value / 100 != 0 ? value / 100 : value / 10
		let inches = value / 100 != 0 ? value % 100 : value % 10
		return (feet, inches)
	}

	static var firstName: String? {
		AppDelegate.careManager.patient?.name.givenName
	}

	static var birthdate: Int? {
		guard let date = AppDelegate.careManager.patient?.birthday else {
			return nil
		}
		return Calendar.current.component(.year, from: date)
	}

	static var gender: OCKBiologicalSex {
		AppDelegate.careManager.patient?.sex ?? .female
	}

	static func getGoal(for type: HealthKitQuantityType) -> Int {
		switch type {
		case .weight:
			return AppDelegate.careManager.patient?.measurementWeightGoal ?? 0
		case .bloodPressure:
			return AppDelegate.careManager.patient?.measurementBloodPressureGoal ?? 0
		case .activity:
			return AppDelegate.careManager.patient?.measurementStepsGoal ?? 0
		case .heartRate:
			return AppDelegate.careManager.patient?.measurementHeartRateGoal ?? 0
		case .restingHeartRate:
			return AppDelegate.careManager.patient?.measurementRestingHeartRateGoal ?? 0
		}
	}
}
