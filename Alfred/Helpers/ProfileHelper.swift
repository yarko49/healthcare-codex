import Foundation

class ProfileHelper {
	static func computeHeight(value: Int) -> (Int, Int) {
		let feet = value / 100 != 0 ? value / 100 : value / 10
		let inches = value / 100 != 0 ? value % 100 : value % 10
		return (feet, inches)
	}

	static var firstName: String {
		DataContext.shared.displayFirstName
	}

	static var birthdate: Int {
		DataContext.shared.birthdayYear
	}

	static var gender: Gender {
		var gender: Gender?
		if DataContext.shared.userModel?.gender == .male {
			gender = .male
		} else if DataContext.shared.userModel?.gender == .female {
			gender = .female
		}
		return gender ?? Gender.female
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
