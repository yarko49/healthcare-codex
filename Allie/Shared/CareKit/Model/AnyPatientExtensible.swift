//
//  OCKPatient+CodexResource.swift
//  Allie
//
//  Created by Waqar Malik on 1/10/21.
//

import CareKitStore
import UIKit

public protocol AnyPatientExtensible: AnyUserInfoExtensible {
	var weight: Int? { get set }
	var height: Int? { get set }
	var email: String? { get set }
	var phoneNumber: String? { get set }
	var versionId: String? { get set }
	var deviceManufacturer: String? { get set }
	var deviceSoftwareVersion: String? { get set }
	var FHIRId: String? { get set }
	var measurementWeightGoal: Int? { get set }
	var isMeasurementWeightEnabled: Bool { get set }
	var isMeasurementWeightNotificationEnabled: Bool { get set }
	var measurementBloodPressureGoal: Int? { get set }
	var isMeasurementBloodPressureEnabled: Bool { get set }
	var isMeasurementBloodPressureNotificationEnabled: Bool { get set }
	var measurementHeartRateGoal: Int? { get set }
	var isMeasurementHeartRateEnabled: Bool { get set }
	var isMeasurementHeartRateNotificationEnabled: Bool { get set }
	var measurementRestingHeartRateGoal: Int? { get set }
	var isMeasurementRestingHeartRateEnabled: Bool { get set }
	var isMeasurementRestingHeartRateNotificationEnabled: Bool { get set }
	var measurementStepsGoal: Int? { get set }
	var isMeasurementStepsEnabled: Bool { get set }
	var isMeasurementStepsNotificationEnabled: Bool { get set }
	var measurementBloodGlucoseGoal: Int? { get set }
	var isMeasurementBloodGlucoseEnabled: Bool { get set }
	var isMeasurementBloodGlucoseNotificationEnabled: Bool { get set }
	var notificationsEnabled: Bool { get set }
	var isSignUpCompleted: Bool { get set }
}

extension OCKPatient: AnyPatientExtensible {}

public extension AnyPatientExtensible {
	var weight: Int? {
		get {
			getInt(forKey: "weight")
		}
		set {
			set(integer: newValue ?? 0, forKey: "weight")
		}
	}

	var height: Int? {
		get {
			getInt(forKey: "height")
		}
		set {
			set(integer: newValue ?? 0, forKey: "height")
		}
	}

	var email: String? {
		get {
			userInfo?["email"]
		}
		set {
			setUserInfo(string: newValue, forKey: "email")
		}
	}

	var phoneNumber: String? {
		get {
			userInfo?["phoneNumber"]
		}
		set {
			setUserInfo(string: newValue, forKey: "phoneNumber")
		}
	}

	var versionId: String? {
		get {
			userInfo?["versionId"]
		}
		set {
			setUserInfo(string: newValue, forKey: "versionId")
		}
	}

	var deviceManufacturer: String? {
		get {
			userInfo?["deviceManufacturer"]
		}
		set {
			setUserInfo(string: newValue, forKey: "deviceManufacturer")
		}
	}

	var deviceSoftwareVersion: String? {
		get {
			userInfo?["deviceSoftwareVersion"]
		}
		set {
			setUserInfo(string: newValue, forKey: "deviceSoftwareVersion")
		}
	}

	var FHIRId: String? {
		get {
			userInfo?["FHIRId"]
		}
		set {
			setUserInfo(string: newValue, forKey: "FHIRId")
		}
	}

	var measurementWeightGoal: Int? {
		get {
			getInt(forKey: "measurementWeightGoal")
		}
		set {
			set(integer: newValue ?? 0, forKey: "measurementWeightGoal")
		}
	}

	var isMeasurementWeightEnabled: Bool {
		get {
			getBool(forKey: "measurementWeightEnabled")
		}
		set {
			set(bool: newValue, forKey: "measurementWeightEnabled")
		}
	}

	var isMeasurementWeightNotificationEnabled: Bool {
		get {
			getBool(forKey: "measurementWeightNotificationEnabled")
		}
		set {
			set(bool: newValue, forKey: "measurementWeightNotificationEnabled")
		}
	}

	var measurementBloodPressureGoal: Int? {
		get {
			getInt(forKey: "measurementBloodPressureGoal")
		}
		set {
			set(integer: newValue ?? 0, forKey: "measurementBloodPressureGoal")
		}
	}

	var isMeasurementBloodPressureEnabled: Bool {
		get {
			getBool(forKey: "measurementBloodPressureEnabled")
		}
		set {
			set(bool: newValue, forKey: "measurementBloodPressureEnabled")
		}
	}

	var isMeasurementBloodPressureNotificationEnabled: Bool {
		get {
			getBool(forKey: "measurementBloodPressureNotificationEnabled")
		}
		set {
			set(bool: newValue, forKey: "measurementBloodPressureNotificationEnabled")
		}
	}

	var measurementHeartRateGoal: Int? {
		get {
			getInt(forKey: "measurementHeartRateGoal")
		}
		set {
			set(integer: newValue ?? 0, forKey: "measurementHeartRateGoal")
		}
	}

	var isMeasurementHeartRateEnabled: Bool {
		get {
			getBool(forKey: "measurementHeartRateEnabled")
		}
		set {
			set(bool: newValue, forKey: "measurementHeartRateEnabled")
		}
	}

	var isMeasurementHeartRateNotificationEnabled: Bool {
		get {
			getBool(forKey: "measurementHeartRateNotificationEnabled")
		}
		set {
			set(bool: newValue, forKey: "measurementHeartRateNotificationEnabled")
		}
	}

	var measurementRestingHeartRateGoal: Int? {
		get {
			getInt(forKey: "measurementRestingHeartRateGoal")
		}
		set {
			set(integer: newValue ?? 0, forKey: "measurementRestingHeartRateGoal")
		}
	}

	var isMeasurementRestingHeartRateEnabled: Bool {
		get {
			getBool(forKey: "measurementRestingHeartRateEnabled")
		}
		set {
			set(bool: newValue, forKey: "measurementRestingHeartRateEnabled")
		}
	}

	var isMeasurementRestingHeartRateNotificationEnabled: Bool {
		get {
			getBool(forKey: "measurementRestingHeartRateNotificationEnabled")
		}
		set {
			set(bool: newValue, forKey: "measurementRestingHeartRateNotificationEnabled")
		}
	}

	var measurementStepsGoal: Int? {
		get {
			getInt(forKey: "measurementStepsGoal")
		}
		set {
			set(integer: newValue ?? 0, forKey: "measurementStepsGoal")
		}
	}

	var isMeasurementStepsEnabled: Bool {
		get {
			getBool(forKey: "measurementStepsEnabled")
		}
		set {
			set(bool: newValue, forKey: "measurementStepsEnabled")
		}
	}

	var isMeasurementStepsNotificationEnabled: Bool {
		get {
			getBool(forKey: "measurementStepsNotificationEnabled")
		}
		set {
			set(bool: newValue, forKey: "measurementStepsNotificationEnabled")
		}
	}

	var measurementBloodGlucoseGoal: Int? {
		get {
			getInt(forKey: "measurementBloodGlucoseGoal")
		}
		set {
			set(integer: newValue ?? 0, forKey: "measurementBloodGlucoseGoal")
		}
	}

	var isMeasurementBloodGlucoseEnabled: Bool {
		get {
			getBool(forKey: "measurementBloodGlucoseEnabled")
		}
		set {
			set(bool: newValue, forKey: "measurementBloodGlucoseEnabled")
		}
	}

	var isMeasurementBloodGlucoseNotificationEnabled: Bool {
		get {
			getBool(forKey: "measurementBloodGlucoseNotificationEnabled")
		}
		set {
			set(bool: newValue, forKey: "measurementBloodGlucoseNotificationEnabled")
		}
	}

	var notificationsEnabled: Bool {
		get {
			getBool(forKey: "notificationsEnabled")
		}
		set {
			set(bool: newValue, forKey: "notificationsEnabled")
		}
	}

	var isSignUpCompleted: Bool {
		get {
			getBool(forKey: "signUpCompleted")
		}
		set {
			set(bool: newValue, forKey: "signUpCompleted")
		}
	}
}
