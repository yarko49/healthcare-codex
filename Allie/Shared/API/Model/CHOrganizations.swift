//
//  CHOrganization.swift
//  Allie
//
//  Created by Waqar Malik on 5/27/21.
//

import Foundation

struct CHOrganizations: Codable, Hashable {
	let available: [CHOrganization]
	let registered: [CHOrganization]

	private enum CodingKeys: String, CodingKey {
		case available = "availableOrganizations"
		case registered = "registeredOrganizations"
	}
}

struct CHOrganization: Codable, Identifiable, Hashable {
	let id: String
	let name: String
	let imageURL: URL?
	let detailImageURL: URL?
	let authURL: URL?
	let totalPatients: Int
	let info: String?

	init(id: String) {
		self.id = id
		self.name = NSLocalizedString("UNKNOWN_ORGANIZATION", comment: "Unknown Organization")
		self.imageURL = nil
		self.detailImageURL = nil
		self.authURL = nil
		self.totalPatients = 0
		self.info = nil
	}

	private enum CodingKeys: String, CodingKey {
		case id = "healthcareProviderTenantId"
		case name
		case imageURL = "image"
		case detailImageURL = "detailImage"
		case authURL = "authUrl"
		case totalPatients
		case info = "description"
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(id.hashValue)
	}

	static func == (lhs: CHOrganization, rhs: CHOrganization) -> Bool {
		lhs.id == rhs.id
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(String.self, forKey: .id)
		self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? NSLocalizedString("UNKNOWN_ORGANIZATION", comment: "Unknown Organization")
		self.imageURL = try container.decodeIfPresent(URL.self, forKey: .imageURL)
		self.detailImageURL = try container.decodeIfPresent(URL.self, forKey: .detailImageURL)
		self.authURL = try container.decodeIfPresent(URL.self, forKey: .authURL)
		self.totalPatients = try container.decodeIfPresent(Int.self, forKey: .totalPatients) ?? 0
		self.info = try container.decodeIfPresent(String.self, forKey: .info)
	}
}

extension CHOrganization: CustomStringConvertible {
	var description: String {
		name
	}
}

extension CHOrganization: CustomDebugStringConvertible {
	var debugDescription: String {
		"{\n\tId = \(id)\n\tName = \(name)\n}"
	}
}

extension CHOrganization {
	var message: String? {
		info ?? NSLocalizedString("PROVIDER_CONSENT.message", comment: "By connected your account to the provider you agree to share your medical data with provider.")
	}
}
