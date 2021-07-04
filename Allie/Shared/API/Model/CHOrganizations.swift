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
	let name: String?
	let imageURL: URL?
	let detailImageURL: URL?
	let authURL: URL?
	let totalPatients: Int
	let info: String?

	init(id: String) {
		self.id = id
		self.name = "Unknown"
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
}

extension CHOrganization: CustomStringConvertible {
	var description: String {
		name ?? "Unknown Organization"
	}
}

extension CHOrganization: CustomDebugStringConvertible {
	var debugDescription: String {
		"{\n\tId = \(id)\n\tName = \(name ?? "Unknown Organization")\n}"
	}
}

extension CHOrganization {
	var message: String? {
		info ?? NSLocalizedString("PROVIDER_CONSENT.message", comment: "By connected your account to the provider you agree to share your medical data with provider.")
	}
}
