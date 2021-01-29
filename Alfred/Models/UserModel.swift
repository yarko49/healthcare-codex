import CareKitStore
import Foundation

struct UserModel {
	var userID: String?
	var email: String?
	var name: [ResourceName]?
	var dob: String?
	var gender: OCKBiologicalSex?
}

extension UserModel {
	var displayLastName: String {
		var displayName: [String] = []
		if let names = name {
			names.forEach { name in
				displayName.append(name.family ?? "")
			}
		}
		return displayName.joined(separator: " ")
	}

	var displayName: String {
		var displayName: [String] = []
		if let names = name {
			names.forEach { name in
				displayName.append(contentsOf: name.given ?? [])
				displayName.append(name.family ?? "")
			}
		}
		return displayName.joined(separator: " ")
	}

	var displayFirstName: String {
		var displayName: [String] = []
		if let names = name {
			names.forEach { name in
				displayName.append(contentsOf: name.given ?? [])
			}
		}
		return displayName.joined(separator: " ")
	}

	var patientID: String {
		"Patient/\(userID ?? "")"
	}

	var birthdayYear: Int {
		let age = dob
		let yearString = age?.prefix(4)
		let year = String(yearString ?? "")
		let dobYear = Int(year)

		return dobYear ?? 0
	}
}
