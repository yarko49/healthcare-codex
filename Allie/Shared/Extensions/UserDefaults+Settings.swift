//
//  UserDefaults+Settings.swift
//  Allie
//
//  Created by Waqar Malik on 1/26/21.
//

import Foundation

extension UserDefaults {
	enum Keys: String {
		case hasRunOnce = "HAS_RUN_ONCE"
		case hasCompletedOnboarding = "HAS_COMPLETED_ONBOARDING"
		case isBiometricsEnabled = "IS_BIOMETRICS_ENABLED"
		case haveAskedUserForBiometrics
		case hasSmartScale
		case hasSmartBloodPressureCuff
		case hasSmartWatch
		case hasSmartPedometer
		case hasSmartBloodGlucoseMonitor
		case vectorClock
		case measurementStepsNotificationEnabled
		case measurementBloodPressureNotificationEnabled
		case measurementWeightNotificationEnabled
		case measurementBloodGlucoseNotificationEnabled
		case measurementBloodPressureGoal
		case measurementHeartRateGoal
		case measurementRestingHeartRateGoal
		case measurementStepsGoal
		case measurementWeightInPoundsGoal
		case lastObervationUploadDate
	}

	static func registerDefautlts() {
		let defaults: [String: Any] = [Self.Keys.hasRunOnce.rawValue: false, Self.Keys.hasCompletedOnboarding.rawValue: false,
		                               Self.Keys.isBiometricsEnabled.rawValue: false, Self.Keys.haveAskedUserForBiometrics.rawValue: false]
		UserDefaults.standard.register(defaults: defaults)
	}

	var hasRunOnce: Bool {
		get {
			bool(forKey: Self.Keys.hasRunOnce.rawValue)
		}
		set {
			set(newValue, forKey: Self.Keys.hasRunOnce.rawValue)
		}
	}

	var hasCompletedOnboarding: Bool {
		get {
			bool(forKey: Self.Keys.hasCompletedOnboarding.rawValue)
		}
		set {
			set(newValue, forKey: Self.Keys.hasCompletedOnboarding.rawValue)
		}
	}

	var isBiometricsEnabled: Bool {
		get {
			bool(forKey: Self.Keys.isBiometricsEnabled.rawValue)
		}
		set {
			set(newValue, forKey: Self.Keys.isBiometricsEnabled.rawValue)
		}
	}

	var haveAskedUserForBiometrics: Bool {
		get {
			bool(forKey: Self.Keys.haveAskedUserForBiometrics.rawValue)
		}
		set {
			set(newValue, forKey: Self.Keys.haveAskedUserForBiometrics.rawValue)
		}
	}

	var hasSmartScale: Bool {
		get {
			bool(forKey: Self.Keys.hasSmartScale.rawValue)
		}
		set {
			set(newValue, forKey: Self.Keys.hasSmartScale.rawValue)
		}
	}

	var hasSmartBloodPressureCuff: Bool {
		get {
			bool(forKey: Self.Keys.hasSmartBloodPressureCuff.rawValue)
		}
		set {
			set(newValue, forKey: Self.Keys.hasSmartBloodPressureCuff.rawValue)
		}
	}

	var hasSmartWatch: Bool {
		get {
			bool(forKey: Self.Keys.hasSmartWatch.rawValue)
		}
		set {
			set(newValue, forKey: Self.Keys.hasSmartWatch.rawValue)
		}
	}

	var hasSmartPedometer: Bool {
		get {
			bool(forKey: Self.Keys.hasSmartPedometer.rawValue)
		}
		set {
			set(newValue, forKey: Self.Keys.hasSmartPedometer.rawValue)
		}
	}

	var hasSmartBloodGlucoseMonitor: Bool {
		get {
			bool(forKey: Self.Keys.hasSmartBloodGlucoseMonitor.rawValue)
		}
		set {
			set(newValue, forKey: Self.Keys.hasSmartBloodGlucoseMonitor.rawValue)
		}
	}

	func removeBiometrics() {
		removeObject(forKey: Self.Keys.isBiometricsEnabled.rawValue)
	}

	var vectorClock: [String: Int] {
		get {
			object(forKey: Self.Keys.vectorClock.rawValue) as? [String: Int] ?? [:]
		}
		set {
			set(newValue, forKey: Self.Keys.vectorClock.rawValue)
		}
	}

	var isMeasurementStepsNotificationEnabled: Bool {
		get {
			bool(forKey: Self.Keys.measurementStepsNotificationEnabled.rawValue)
		}
		set {
			set(newValue, forKey: Self.Keys.measurementStepsNotificationEnabled.rawValue)
		}
	}

	var isMeasurementBloodPressureNotificationEnabled: Bool {
		get {
			bool(forKey: Self.Keys.measurementBloodPressureNotificationEnabled.rawValue)
		}
		set {
			set(newValue, forKey: Self.Keys.measurementBloodPressureNotificationEnabled.rawValue)
		}
	}

	var isMeasurementWeightNotificationEnabled: Bool {
		get {
			bool(forKey: Self.Keys.measurementWeightNotificationEnabled.rawValue)
		}
		set {
			set(newValue, forKey: Self.Keys.measurementWeightNotificationEnabled.rawValue)
		}
	}

	var isMeasurementBloodGlucoseNotificationEnabled: Bool {
		get {
			bool(forKey: Self.Keys.measurementBloodGlucoseNotificationEnabled.rawValue)
		}
		set {
			set(newValue, forKey: Self.Keys.measurementBloodGlucoseNotificationEnabled.rawValue)
		}
	}

	var measurementBloodPressureGoal: Int {
		get {
			integer(forKey: Self.Keys.measurementBloodPressureGoal.rawValue)
		}
		set {
			setValue(newValue, forKey: Self.Keys.measurementBloodPressureGoal.rawValue)
		}
	}

	var measurementHeartRateGoal: Int {
		get {
			integer(forKey: Self.Keys.measurementHeartRateGoal.rawValue)
		}
		set {
			setValue(newValue, forKey: Self.Keys.measurementHeartRateGoal.rawValue)
		}
	}

	var measurementRestingHeartRateGoal: Int {
		get {
			integer(forKey: Self.Keys.measurementRestingHeartRateGoal.rawValue)
		}
		set {
			setValue(newValue, forKey: Self.Keys.measurementRestingHeartRateGoal.rawValue)
		}
	}

	var measurementStepsGoal: Int {
		get {
			integer(forKey: Self.Keys.measurementStepsGoal.rawValue)
		}
		set {
			setValue(newValue, forKey: Self.Keys.measurementStepsGoal.rawValue)
		}
	}

	var measurementWeightInPoundsGoal: Int {
		get {
			integer(forKey: Self.Keys.measurementWeightInPoundsGoal.rawValue)
		}
		set {
			setValue(newValue, forKey: Self.Keys.measurementWeightInPoundsGoal.rawValue)
		}
	}

	var lastObervationUploadDate: Date {
		get {
			let date = Date()
			return object(forKey: Self.Keys.lastObervationUploadDate.rawValue) as? Date ?? Calendar.current.date(byAdding: .day, value: -14, to: date) ?? date
		}
		set {
			setValue(newValue, forKey: Self.Keys.lastObervationUploadDate.rawValue)
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
