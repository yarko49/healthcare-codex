//
//  UserDefaults+Settings.swift
//  Allie
//
//  Created by Waqar Malik on 1/26/21.
//

import Foundation

extension UserDefaults {
	static func registerDefautlts() {
		let defaults: [String: Any] = [Self.isCarePlanPopulatedKey: false, Self.hasRunOnceKey: false, Self.hasCompletedOnboardingKey: false,
		                               Self.isBiometricsEnabledKey: false, Self.healthKitUploadChunkSizeKey: 4500, Self.haveAskedUserForBiometricsKey: false]
		UserDefaults.standard.register(defaults: defaults)
	}

	private static let isCarePlanPopulatedKey = "carePlanPopulated"
	var isCarePlanPopulated: Bool {
		get {
			bool(forKey: Self.isCarePlanPopulatedKey)
		}
		set {
			set(newValue, forKey: Self.isCarePlanPopulatedKey)
		}
	}

	private static let hasRunOnceKey = "HAS_RUN_ONCE"
	var hasRunOnce: Bool {
		get {
			bool(forKey: Self.hasRunOnceKey)
		}
		set {
			set(newValue, forKey: Self.hasRunOnceKey)
		}
	}

	private static let hasCompletedOnboardingKey = "HAS_COMPLETED_ONBOARDING"
	var hasCompletedOnboarding: Bool {
		get {
			bool(forKey: Self.hasCompletedOnboardingKey)
		}
		set {
			set(newValue, forKey: Self.hasCompletedOnboardingKey)
		}
	}

	private static let isBiometricsEnabledKey = "IS_BIOMETRICS_ENABLED"
	var isBiometricsEnabled: Bool {
		get {
			bool(forKey: Self.isBiometricsEnabledKey)
		}
		set {
			set(newValue, forKey: Self.isBiometricsEnabledKey)
		}
	}

	private static let haveAskedUserForBiometricsKey = "haveAskedUserForBiometrics"
	var haveAskedUserForBiometrics: Bool {
		get {
			bool(forKey: Self.haveAskedUserForBiometricsKey)
		}
		set {
			set(newValue, forKey: Self.haveAskedUserForBiometricsKey)
		}
	}

	private static let hasSmartScaleKey = "hasSmartScale"
	var hasSmartScale: Bool {
		get {
			bool(forKey: Self.hasSmartScaleKey)
		}
		set {
			set(newValue, forKey: Self.hasSmartScaleKey)
		}
	}

	private static let hasSmartBloodPressureCuffKey = "hasSmartBloodPressureCuff"
	var hasSmartBloodPressureCuff: Bool {
		get {
			bool(forKey: Self.hasSmartBloodPressureCuffKey)
		}
		set {
			set(newValue, forKey: Self.hasSmartBloodPressureCuffKey)
		}
	}

	private static let hasSmartWatchKey = "hasSmartWatch"
	var hasSmartWatch: Bool {
		get {
			bool(forKey: Self.hasSmartWatchKey)
		}
		set {
			set(newValue, forKey: Self.hasSmartWatchKey)
		}
	}

	private static let hasSmartPedometerKey = "hasSmartPedometer"
	var hasSmartPedometer: Bool {
		get {
			bool(forKey: Self.hasSmartPedometerKey)
		}
		set {
			set(newValue, forKey: Self.hasSmartPedometerKey)
		}
	}

	private static let hasSmartBloodGlucoseMonitorKey = "hasSmartBloodGlucoseMonitor"
	var hasSmartBloodGlucoseMonitor: Bool {
		get {
			bool(forKey: Self.hasSmartBloodGlucoseMonitorKey)
		}
		set {
			set(newValue, forKey: Self.hasSmartBloodGlucoseMonitorKey)
		}
	}

	func removeBiometrics() {
		removeObject(forKey: Self.isBiometricsEnabledKey)
	}

	private static let healthKitUploadChunkSizeKey = "HealthKitUploadChunkSize"
	var healthKitUploadChunkSize: Int {
		get {
			integer(forKey: Self.healthKitUploadChunkSizeKey)
		}
		set {
			set(newValue, forKey: Self.healthKitUploadChunkSizeKey)
		}
	}

	private static let vectorClockKey = "vectorClock"
	var vectorClock: [String: Int] {
		get {
			object(forKey: Self.vectorClockKey) as? [String: Int] ?? [:]
		}
		set {
			set(newValue, forKey: Self.vectorClockKey)
		}
	}
}
