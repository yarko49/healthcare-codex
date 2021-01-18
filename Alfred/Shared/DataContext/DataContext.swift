import Combine
import FirebaseAuth
import Foundation

class DataContext: ObservableObject {
	static let shared = DataContext()

	var hasRunOnce: Bool {
		get {
			UserDefaults.standard.bool(forKey: "HAS_RUN_ONCE")
		}
		set {
			UserDefaults.standard.set(newValue, forKey: "HAS_RUN_ONCE")
		}
	}

	var hasCompletedOnboarding: Bool {
		get {
			UserDefaults.standard.bool(forKey: "HAS_COMPLETED_ONBOARDING")
		}
		set {
			UserDefaults.standard.set(newValue, forKey: "HAS_COMPLETED_ONBOARDING")
		}
	}

	var isBiometricsEnabled: Bool {
		get {
			UserDefaults.standard.bool(forKey: "IS_BIOMETRICS_ENABLED")
		}
		set {
			UserDefaults.standard.set(newValue, forKey: "IS_BIOMETRICS_ENABLED")
		}
	}

	var haveAskedUserforBiometrics: Bool {
		UserDefaults.standard.object(forKey: "IS_BIOMETRICS_ENABLED") != nil
	}

	func removeBiometrics() {
		UserDefaults.standard.removeObject(forKey: "IS_BIOMETRICS_ENABLED")
	}

	var userAuthorizedQuantities: [HealthKitQuantityType] = [.weight, .activity, .bloodPressure, .restingHeartRate, .heartRate]
	var healthKitIntervals: [HealthStatsDateIntervalType] = [.daily, .weekly, .monthly, .yearly]

	var appVersion: String? {
		Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
	}

	let remoteConfigManager = RemoteConfigManager()
	var hasSmartScale = false
	var hasSmartBlockPressureCuff = false
	var hasSmartWatch = false
	var hasSmartPedometer = false
	var updatePatient: UpdatePatientModels?

	@Published var resouce: CodexResource? {
		willSet {
			objectWillChange.send()
		}
	}

	@Published var userModel: UserModel? {
		willSet {
			objectWillChange.send()
		}
	}

	var dataModel: CodexBundle?
	var weightArray: [Int] = []
	var heightArray: [Int] = []

	var weightGoal = 0.0
	var bpGoal = 0.0
	var stepsGoal = 0.0
	var hrGoal = 0.0
	var rhrGoal = 0.0
	var activityPushNotificationsIsOn = false
	var bloodPressurePushNotificationsIsOn = false
	var weightInPushNotificationsIsOn = false
	var surveyPushNotificationsIsOn = false
	var signUpCompleted = false
	var firstName: String?

	var displayLastName: String {
		var displayName: [String] = []
		if let names = userModel?.name {
			names.forEach { name in
				displayName.append(name.family ?? "")
			}
		}
		return displayName.joined(separator: " ")
	}

	func getDate() -> Date? {
		let date = Date()
		let calendar = Calendar.current
		var newComponents = DateComponents()
		newComponents.timeZone = .current
		newComponents.second = calendar.component(.second, from: date)
		newComponents.minute = calendar.component(.minute, from: date)
		newComponents.hour = calendar.component(.hour, from: date)
		newComponents.day = calendar.component(.day, from: date)
		newComponents.month = calendar.component(.month, from: date)
		newComponents.year = calendar.component(.year, from: date)
		return calendar.date(from: newComponents)
	}

	var displayName: String {
		var displayName: [String] = []
		if let names = userModel?.name {
			names.forEach { name in
				displayName.append(contentsOf: name.given ?? [])
				displayName.append(name.family ?? "")
			}
		}
		return displayName.joined(separator: " ")
	}

	var displayFirstName: String {
		var displayName: [String] = []
		if let names = userModel?.name {
			names.forEach { name in
				displayName.append(contentsOf: name.given ?? [])
			}
		}
		return displayName.joined(separator: " ")
	}

	var patientID: String {
		"Patient/\(userModel?.userID ?? "")"
	}

	var birthdayYear: Int {
		let age = userModel?.dob
		let yearString = age?.prefix(4)
		let year = String(yearString ?? "")
		let dobYear = Int(year)

		return dobYear ?? 0
	}

	var gender: Gender {
		userModel?.gender ?? .female
	}

	let hrCode = Code(coding: [Coding(system: "http://loinc.org", code: "8867-4", display: "Heart rate")])
	let restingHRCode = Code(coding: [Coding(system: "http://loinc.org", code: "40443-4", display: "Heart rate Resting")])
	let bpCode = Code(coding: [Coding(system: "http://loinc.org", code: "85354-9", display: "Blood pressure systolic and diastolic")])
	let weightCode = Code(coding: [Coding(system: "http://loinc.org", code: "29463-7", display: "Body weight"), Coding(system: "http://loinc.org", code: "3141-9", display: "Body weight measured"), Coding(system: "http://snomed.info/sct", code: "27113001", display: "Body weight")])
	let idealWeightCode = Code(coding: [Coding(system: "http://loinc.org", code: "50064-5", display: "Ideal body weight")])
	let heightCode = Code(coding: [Coding(system: "http://loinc.org", code: "8302-2", display: "Body height")])
	let diastolicBPCode = Code(coding: [Coding(system: "http://loinc.org", code: "8462-4", display: "Diastolic blood pressure")])
	let systolicBPCode = Code(coding: [Coding(system: "http://loinc.org", code: "8480-6", display: "Systolic blood pressure"), Coding(system: "http://snomed.info/sct", code: "271649006", display: "Systolic blood pressure")])
	let stepsCode = Code(coding: [Coding(system: "http://loinc.org", code: "55423-8", display: "Number of steps")])

	var getObservationData: CodexBundle?

	func clearAll() {
		clearKeychain()
		clearVariables()
	}

	func clearVariables() {
		hasSmartScale = false
		hasSmartBlockPressureCuff = false
		hasSmartWatch = false
		hasSmartPedometer = false
		activityPushNotificationsIsOn = false
		bloodPressurePushNotificationsIsOn = false
		weightInPushNotificationsIsOn = false
		surveyPushNotificationsIsOn = false
		weightGoal = 0.0
		bpGoal = 0.0
		stepsGoal = 0.0
		hrGoal = 0.0
		rhrGoal = 0.0
		userModel = nil
	}
}
