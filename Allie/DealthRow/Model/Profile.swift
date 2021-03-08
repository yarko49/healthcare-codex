//
//  ProfileResponse.swift
//  Allie
//
//  Created by Waqar Malik on 12/16/20.
//

import Foundation

struct ProfileResponse: Codable {}

struct Profile: Codable {
	let notificationsEnabled: Bool?
	let registrationToken: String?
	let healthMeasurements: HealthMeasurements?
	let devices: Devices?
	let signUpCompleted: Bool?
}

struct Devices: Codable {
	let additionalProp1: Device?
	let additionalProp2: Device?
	let additionalProp3: Device?

	struct Device: Codable {
		let model: String?
		let version: String?
		let id: String?
		let lastSyncTime: String? // Should this be date
		let manufacturer: String?
		let name: String?
		let softwareVersion: String?

		private enum CodingKeys: String, CodingKey {
			case model = "deviceModel"
			case version = "deviceVersion"
			case id
			case lastSyncTime
			case manufacturer
			case name = "softwareName"
			case softwareVersion
		}
	}
}

struct HealthMeasurements: Codable {
	let heartRate: Measuremement?
	let restingHeartRate: Measuremement?
	let steps: Measuremement?
	let weight: Measuremement?
	let bloodPressure: Measuremement?

	struct Measuremement: Codable {
		let notificationsEnabled: Bool?
		let available: Bool?
		let goal: Double?
	}
}
