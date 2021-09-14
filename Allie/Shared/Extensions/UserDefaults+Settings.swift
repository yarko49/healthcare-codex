//
//  UserDefaults+Settings.swift
//  Allie
//
//  Created by Waqar Malik on 1/26/21.
//

import Foundation

extension UserDefaults {
	subscript<T: Codable>(codable: String) -> T? {
		get {
			guard let data = data(forKey: codable) else {
				return nil
			}
			return try? JSONDecoder().decode(T.self, from: data)
		}
		set {
			guard let encodable = newValue else {
				removeObject(forKey: codable)
				return
			}
			let data = try? JSONEncoder().encode(encodable)
			setValue(data, forKey: codable)
		}
	}
}

extension UserDefaults {
	enum Keys {
		static let hasCompletedOnboarding = "HAS_COMPLETED_ONBOARDING"
		static let isBiometricsEnabled = "IS_BIOMETRICS_ENABLED"
		static let haveAskedUserForBiometrics = "haveAskedUserForBiometrics"
		static let hasSmartScale = "hasSmartScale"
		static let hasSmartBloodPressureCuff = "hasSmartBloodPressureCuff"
		static let hasSmartWatch = "hasSmartWatch"
		static let hasSmartPedometer = "hasSmartPedometer"
		static let hasSmartBloodGlucoseMonitor = "hasSmartBloodGlucoseMonitor"
		static let vectorClock = "vectorClock"
		static let measurementStepsNotificationEnabled = "measurementStepsNotificationEnabled"
		static let measurementBloodPressureNotificationEnabled = "measurementBloodPressureNotificationEnabled"
		static let measurementWeightNotificationEnabled = "measurementWeightNotificationEnabled"
		static let measurementBloodGlucoseNotificationEnabled = "measurementBloodGlucoseNotificationEnabled"
		static let lastObervationUploadDate = "lastObervationUploadDate"
		static let chatNotificationsCount = "chatNotificationsCount"
	}

	static func registerDefautlts() {
		let defaults: [String: Any] = [Self.Keys.hasCompletedOnboarding: false,
		                               Self.Keys.isBiometricsEnabled: false, Self.Keys.haveAskedUserForBiometrics: false]
		UserDefaults.standard.register(defaults: defaults)
	}

	var hasCompletedOnboarding: Bool {
		get {
			bool(forKey: Self.Keys.hasCompletedOnboarding)
		}
		set {
			set(newValue, forKey: Self.Keys.hasCompletedOnboarding)
		}
	}

	var isBiometricsEnabled: Bool {
		get {
			bool(forKey: Self.Keys.isBiometricsEnabled)
		}
		set {
			set(newValue, forKey: Self.Keys.isBiometricsEnabled)
		}
	}

	var haveAskedUserForBiometrics: Bool {
		get {
			bool(forKey: Self.Keys.haveAskedUserForBiometrics)
		}
		set {
			set(newValue, forKey: Self.Keys.haveAskedUserForBiometrics)
		}
	}

	var hasSmartScale: Bool {
		get {
			bool(forKey: Self.Keys.hasSmartScale)
		}
		set {
			set(newValue, forKey: Self.Keys.hasSmartScale)
		}
	}

	var hasSmartBloodPressureCuff: Bool {
		get {
			bool(forKey: Self.Keys.hasSmartBloodPressureCuff)
		}
		set {
			set(newValue, forKey: Self.Keys.hasSmartBloodPressureCuff)
		}
	}

	var hasSmartWatch: Bool {
		get {
			bool(forKey: Self.Keys.hasSmartWatch)
		}
		set {
			set(newValue, forKey: Self.Keys.hasSmartWatch)
		}
	}

	var hasSmartPedometer: Bool {
		get {
			bool(forKey: Self.Keys.hasSmartPedometer)
		}
		set {
			set(newValue, forKey: Self.Keys.hasSmartPedometer)
		}
	}

	var hasSmartBloodGlucoseMonitor: Bool {
		get {
			bool(forKey: Self.Keys.hasSmartBloodGlucoseMonitor)
		}
		set {
			set(newValue, forKey: Self.Keys.hasSmartBloodGlucoseMonitor)
		}
	}

	func removeBiometrics() {
		removeObject(forKey: Self.Keys.isBiometricsEnabled)
	}

	var vectorClock: UInt64 {
		get {
			UInt64(integer(forKey: Self.Keys.vectorClock))
		}
		set {
			set(newValue, forKey: Self.Keys.vectorClock)
		}
	}

	var isMeasurementStepsNotificationEnabled: Bool {
		get {
			bool(forKey: Self.Keys.measurementStepsNotificationEnabled)
		}
		set {
			set(newValue, forKey: Self.Keys.measurementStepsNotificationEnabled)
		}
	}

	var isMeasurementBloodPressureNotificationEnabled: Bool {
		get {
			bool(forKey: Self.Keys.measurementBloodPressureNotificationEnabled)
		}
		set {
			set(newValue, forKey: Self.Keys.measurementBloodPressureNotificationEnabled)
		}
	}

	var isMeasurementWeightNotificationEnabled: Bool {
		get {
			bool(forKey: Self.Keys.measurementWeightNotificationEnabled)
		}
		set {
			set(newValue, forKey: Self.Keys.measurementWeightNotificationEnabled)
		}
	}

	var isMeasurementBloodGlucoseNotificationEnabled: Bool {
		get {
			bool(forKey: Self.Keys.measurementBloodGlucoseNotificationEnabled)
		}
		set {
			set(newValue, forKey: Self.Keys.measurementBloodGlucoseNotificationEnabled)
		}
	}

	var lastObervationUploadDate: Date {
		get {
			let date = Date()
			return object(forKey: Self.Keys.lastObervationUploadDate) as? Date ?? Calendar.current.date(byAdding: .day, value: -14, to: date) ?? date
		}
		set {
			setValue(newValue, forKey: Self.Keys.lastObervationUploadDate)
		}
	}

	var chatNotificationsCount: Int {
		get {
			integer(forKey: Keys.chatNotificationsCount)
		} set {
			setValue(newValue, forKey: Keys.chatNotificationsCount)
		}
	}

	func resetUserDefaults() {
		let dictionary = dictionaryRepresentation()
		for (key, _) in dictionary {
			removeObject(forKey: key)
		}
	}

	subscript(lastOutcomesUploadDate key: String) -> Date {
		get {
			let now = Date()
			return value(forKey: key + "LastOutcomesUpload") as? Date ?? Calendar.current.date(byAdding: .day, value: -14, to: now) ?? now
		}
		set {
			setValue(newValue, forKey: key + "LastOutcomesUpload")
		}
	}
}
