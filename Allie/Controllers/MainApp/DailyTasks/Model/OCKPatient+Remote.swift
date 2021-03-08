//
//  OCKPatient+CodexResource.swift
//  Allie
//
//  Created by Waqar Malik on 1/10/21.
//

import CareKitStore
import Foundation

extension OCKPatient: AlliePatientExtensible {
	init?(user: RemoteUser?) {
		guard let identifier = user?.uid else {
			return nil
		}
		var nameComponents = PersonNameComponents()
		if let name = user?.displayName {
			nameComponents = PersonNameComponents(name: name)
		}
		self.init(id: identifier, name: nameComponents)
		self.email = user?.email
		self.phoneNumber = user?.phoneNumber
	}
}

public extension AlliePatientExtensible {
	mutating func setUserInfo(item: String?, forKey key: String) {
		var info = userInfo ?? [:]
		if let value = item {
			info[key] = value
			userInfo = info
		} else {
			userInfo?.removeValue(forKey: key)
		}
	}

	var email: String? {
		get {
			userInfo?["email"]
		}
		set {
			setUserInfo(item: newValue, forKey: "email")
		}
	}

	var phoneNumber: String? {
		get {
			userInfo?["phoneNumber"]
		}
		set {
			setUserInfo(item: newValue, forKey: "phoneNumber")
		}
	}

	var versionId: String? {
		get {
			userInfo?["versionId"]
		}
		set {
			setUserInfo(item: newValue, forKey: "versionId")
		}
	}

	var deviceManufacturer: String? {
		get {
			userInfo?["deviceManufacturer"]
		}
		set {
			setUserInfo(item: newValue, forKey: "deviceManufacturer")
		}
	}

	var deviceSoftwareVersion: String? {
		get {
			userInfo?["deviceSoftwareVersion"]
		}
		set {
			setUserInfo(item: newValue, forKey: "deviceSoftwareVersion")
		}
	}

	var FHIRId: String? {
		get {
			userInfo?["FHIRId"]
		}
		set {
			setUserInfo(item: newValue, forKey: "FHIRId")
		}
	}

	var measurementWeightGoal: Int? {
		get {
			guard let intString = userInfo?["measurementWeightGoal"] else {
				return nil
			}
			return Int(intString)
		}
		set {
			let value = String(newValue ?? 0)
			setUserInfo(item: value, forKey: "measurementWeightGoal")
		}
	}

	var isMeasurementWeightEnabled: Bool {
		get {
			guard let boolString = userInfo?["measurementWeightEnabled"] else {
				return false
			}
			return Bool(boolString) ?? false
		}
		set {
			let boolString = String(newValue)
			setUserInfo(item: boolString, forKey: "measurementWeightEnabled")
		}
	}

	var isMeasurementWeightNotificationEnabled: Bool {
		get {
			guard let boolString = userInfo?["measurementWeightNotificationEnabled"] else {
				return false
			}
			return Bool(boolString) ?? false
		}
		set {
			let boolString = String(newValue)
			setUserInfo(item: boolString, forKey: "measurementWeightNotificationEnabled")
		}
	}

	var isMeasurementBloodPressureEnabled: Bool {
		get {
			guard let boolString = userInfo?["measurementBloodPressureEnabled"] else {
				return false
			}
			return Bool(boolString) ?? false
		}
		set {
			let boolString = String(newValue)
			setUserInfo(item: boolString, forKey: "measurementBloodPressureEnabled")
		}
	}

	var isMeasurementBloodPressureNotificationEnabled: Bool {
		get {
			guard let boolString = userInfo?["measurementBloodPressureNotificationEnabled"] else {
				return false
			}
			return Bool(boolString) ?? false
		}
		set {
			let boolString = String(newValue)
			setUserInfo(item: boolString, forKey: "measurementBloodPressureNotificationEnabled")
		}
	}

	var measurementHeartRateGoal: Int? {
		get {
			guard let intString = userInfo?["measurementHeartRateGoal"] else {
				return nil
			}
			return Int(intString)
		}
		set {
			let value = String(newValue ?? 0)
			setUserInfo(item: value, forKey: "measurementHeartRateGoal")
		}
	}

	var isMeasurementHeartRateEnabled: Bool {
		get {
			guard let boolString = userInfo?["measurementHeartRateEnabled"] else {
				return false
			}
			return Bool(boolString) ?? false
		}
		set {
			let boolString = String(newValue)
			setUserInfo(item: boolString, forKey: "measurementHeartRateEnabled")
		}
	}

	var isMeasurementHeartRateNotificationEnabled: Bool {
		get {
			guard let boolString = userInfo?["measurementHeartRateNotificationEnabled"] else {
				return false
			}
			return Bool(boolString) ?? false
		}
		set {
			let boolString = String(newValue)
			setUserInfo(item: boolString, forKey: "measurementHeartRateNotificationEnabled")
		}
	}

	var measurementRestingHeartRateGoal: Int? {
		get {
			guard let intString = userInfo?["measurementRestingHeartRateGoal"] else {
				return nil
			}
			return Int(intString)
		}
		set {
			let value = String(newValue ?? 0)
			setUserInfo(item: value, forKey: "measurementRestingHeartRateGoal")
		}
	}

	var isMeasurementRestingHeartRateEnabled: Bool {
		get {
			guard let boolString = userInfo?["measurementRestingHeartRateEnabled"] else {
				return false
			}
			return Bool(boolString) ?? false
		}
		set {
			let boolString = String(newValue)
			setUserInfo(item: boolString, forKey: "measurementRestingHeartRateEnabled")
		}
	}

	var isMeasurementRestingHeartRateNotificationEnabled: Bool {
		get {
			guard let boolString = userInfo?["measurementRestingHeartRateNotificationEnabled"] else {
				return false
			}
			return Bool(boolString) ?? false
		}
		set {
			let boolString = String(newValue)
			setUserInfo(item: boolString, forKey: "measurementRestingHeartRateNotificationEnabled")
		}
	}

	var measurementStepsGoal: Int? {
		get {
			guard let intString = userInfo?["measurementStepsGoal"] else {
				return nil
			}
			return Int(intString)
		}
		set {
			let value = String(newValue ?? 0)
			setUserInfo(item: value, forKey: "measurementStepsGoal")
		}
	}

	var isMeasurementStepsEnabled: Bool {
		get {
			guard let boolString = userInfo?["measurementStepsEnabled"] else {
				return false
			}
			return Bool(boolString) ?? false
		}
		set {
			let boolString = String(newValue)
			setUserInfo(item: boolString, forKey: "measurementStepsEnabled")
		}
	}

	var isMeasurementStepsNotificationEnabled: Bool {
		get {
			guard let boolString = userInfo?["measurementStepsNotificationEnabled"] else {
				return false
			}
			return Bool(boolString) ?? false
		}
		set {
			let boolString = String(newValue)
			setUserInfo(item: boolString, forKey: "measurementStepsNotificationEnabled")
		}
	}

	var measurementBloodGlucoseGoal: Int? {
		get {
			guard let intString = userInfo?["measurementBloodGlucoseGoal"] else {
				return nil
			}
			return Int(intString)
		}
		set {
			let value = String(newValue ?? 0)
			setUserInfo(item: value, forKey: "measurementBloodGlucoseGoal")
		}
	}

	var isMeasurementBloodGlucoseEnabled: Bool {
		get {
			guard let boolString = userInfo?["measurementBloodGlucoseEnabled"] else {
				return false
			}
			return Bool(boolString) ?? false
		}
		set {
			let boolString = String(newValue)
			setUserInfo(item: boolString, forKey: "measurementBloodGlucoseEnabled")
		}
	}

	var isMeasurementBloodGlucoseNotificationEnabled: Bool {
		get {
			guard let boolString = userInfo?["measurementBloodGlucoseNotificationEnabled"] else {
				return false
			}
			return Bool(boolString) ?? false
		}
		set {
			let boolString = String(newValue)
			setUserInfo(item: boolString, forKey: "measurementBloodGlucoseNotificationEnabled")
		}
	}

	var notificationsEnabled: Bool {
		get {
			guard let boolString = userInfo?["notificationsEnabled"] else {
				return false
			}
			return Bool(boolString) ?? false
		}
		set {
			let boolString = String(newValue)
			setUserInfo(item: boolString, forKey: "notificationsEnabled")
		}
	}

	var isSignUpCompleted: Bool {
		get {
			guard let boolString = userInfo?["signUpCompleted"] else {
				return false
			}
			return Bool(boolString) ?? false
		}
		set {
			let boolString = String(newValue)
			setUserInfo(item: boolString, forKey: "signUpCompleted")
		}
	}
}
