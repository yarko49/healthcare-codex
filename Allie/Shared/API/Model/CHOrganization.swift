//
//  CHOrganization.swift
//  Allie
//
//  Created by Waqar Malik on 5/27/21.
//

import Foundation

struct CHOrganizationResponse: Codable, Hashable {
	let organizations: [CHOrganization]
}

struct CHOrganization: Codable, Identifiable, Hashable {
	let id: String
	let name: String
	let image: URL?
	let totalPatients: Int

	private enum CodingKeys: String, CodingKey {
		case id = "healthcareProviderTenantId"
		case name
		case image
		case totalPatients
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
