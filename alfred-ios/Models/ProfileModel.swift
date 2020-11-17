
//  ProfileModel.swift
//  alfred-ios

import Foundation

// MARK: - Welcome

struct ProfileModel: Codable {
	let notificationsEnabled: Bool?
	let registrationToken: String?
	let healthMeasurements: HealthMeasurements?
	let devices: Devices?
	let signUpCompleted: Bool?
}

// MARK: - Devices

struct Devices: Codable {
	let additionalProp1, additionalProp2, additionalProp3: AdditionalProp?
}

// MARK: - AdditionalProp

struct AdditionalProp: Codable {
	let deviceModel, deviceVersion, id, lastSyncTime: String?
	let manufacturer, softwareName, softwareVersion: String?
}

// MARK: - HealthMeasurements

struct HealthMeasurements: Codable {
	let heartRate, restingHeartRate, steps: Measuremement?
	let weight, bloodPressure: Measuremement?
}

// MARK: - DiastolicBloodPressure

struct Measuremement: Codable {
	let notificationsEnabled, available: Bool?
}

// MARK: - Profile response

struct ProfileResponse: Codable {}
