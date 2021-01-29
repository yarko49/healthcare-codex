//
//  UserDefaults+Settings.swift
//  Alfred
//
//  Created by Waqar Malik on 1/26/21.
//

import Foundation

extension UserDefaults {
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

	var haveAskedUserforBiometrics: Bool {
		object(forKey: Self.isBiometricsEnabledKey) != nil
	}

	func removeBiometrics() {
		removeObject(forKey: Self.isBiometricsEnabledKey)
	}
}
