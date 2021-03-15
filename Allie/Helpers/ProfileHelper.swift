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

	static func getGoal(for type: HealthKitQuantityType) -> Double {
		switch type {
		case .weight:
			return DataContext.shared.weightGoal
		case .bloodPressure:
			return DataContext.shared.bpGoal
		case .activity:
			return DataContext.shared.stepsGoal
		case .heartRate:
			return DataContext.shared.hrGoal
		case .restingHeartRate:
			return DataContext.shared.rhrGoal
		}
	}
}
