//
//  CHCloudDevices.swift
//  Allie
//
//  Created by Waqar Malik on 11/1/21.
//

import Foundation

struct CHCloudDevices: Codable, Hashable {
	let devices: [CHCloudDevice]
	let registrations: Set<String>

	private enum CodingKeys: String, CodingKey {
		case devices
		case registrations
	}

	init(devices: [CHCloudDevice] = [], registrations: Set<String> = []) {
		self.devices = devices
		self.registrations = registrations
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.devices = try container.decode([CHCloudDevice].self, forKey: .devices)
		let registered = try container.decode([String: [String]].self, forKey: .registrations)
		self.registrations = Set(registered["devices"] ?? [])
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(devices, forKey: .devices)
		let registered = ["devices": Array(registrations)]
		try container.encode(registered, forKey: .registrations)
	}
}

struct CHCloudDevice: Codable, Hashable, Identifiable {
	let id: String
	let name: String
	let info: String?
	let authURL: URL?
	let imageURL: URL?
	var authorizationToken: String?
	var state: String?

	private enum CodingKeys: String, CodingKey {
		case id
		case name = "title"
		case info = "description"
		case authURL = "authUrl"
		case imageURL = "image"
		case authorizationToken = "authCode"
		case state
	}
}
