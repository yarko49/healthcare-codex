import Foundation

class ProfileHelper {
	static func computeHeight(value: Int) -> (Int, Int) {
		let feet = value / 100 != 0 ? value / 100 : value / 10
		let inches = value / 100 != 0 ? value % 100 : value % 10
		return (feet, inches)
	}

	static var firstName: String? {
		DataContext.shared.userModel?.displayFirstName
	}

	static var birthdate: Int? {
		DataContext.shared.userModel?.birthdayYear
	}

	static var gender: Gender {
		guard let gender = DataContext.shared.userModel?.gender, gender == .female || gender == .male else {
			return .female
		}
		return gender
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
