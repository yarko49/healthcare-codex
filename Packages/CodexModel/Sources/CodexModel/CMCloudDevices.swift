//
//  CMCloudDevices.swift
//  Allie
//
//  Created by Waqar Malik on 11/1/21.
//

import Foundation

public struct CMCloudDevices: Codable, Hashable {
	public let devices: [CMCloudDevice]
	public let registrations: Set<String>

	private enum CodingKeys: String, CodingKey {
		case devices
		case registrations
	}

	public init(devices: [CMCloudDevice] = [], registrations: Set<String> = []) {
		self.devices = devices
		self.registrations = registrations
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.devices = try container.decode([CMCloudDevice].self, forKey: .devices)
		let registered = try container.decode([String: [String]].self, forKey: .registrations)
		self.registrations = Set(registered["devices"] ?? [])
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(devices, forKey: .devices)
		let registered = ["devices": Array(registrations)]
		try container.encode(registered, forKey: .registrations)
	}
}

public struct CMCloudDevice: Codable, Hashable, Identifiable {
	public let id: String
	public let name: String
	public let info: String?
	public let authURL: URL?
	public let imageURL: URL?
	public var authorizationToken: String?
	public var state: String?

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
