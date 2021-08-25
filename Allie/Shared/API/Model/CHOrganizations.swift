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
	let authURL: URL?
	let info: String?
	var authorizationToken: String?
	var state: String?

	init(id: String) {
		self.id = id
		self.name = NSLocalizedString("UNKNOWN_ORGANIZATION", comment: "Unknown Organization")
		self.imageURL = nil
		self.authURL = nil
		self.info = nil
		self.authorizationToken = nil
		self.state = nil
	}

	private enum CodingKeys: String, CodingKey {
		case id = "healthcareProviderTenantId"
		case name
		case imageURL = "image"
		case authURL = "authUrl"
		case info = "description"
		case authorizationToken = "authorizationCode"
		case state
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
		let imageURLString = try container.decodeIfPresent(String.self, forKey: .imageURL)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
		self.imageURL = imageURLString.isEmpty ? nil : URL(string: imageURLString)
		let authURLString = try container.decodeIfPresent(String.self, forKey: .authURL)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
		self.authURL = authURLString.isEmpty ? nil : URL(string: authURLString)
		let info = try container.decodeIfPresent(String.self, forKey: .info)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
		self.info = info.isEmpty ? nil : info
		let authorizationCode = try container.decodeIfPresent(String.self, forKey: .authorizationToken)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
		self.authorizationToken = authorizationCode.isEmpty ? nil : authorizationCode
		let state = try container.decodeIfPresent(String.self, forKey: .state)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
		self.state = state.isEmpty ? nil : state
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
