//
//  CHOrganization.swift
//  Allie
//
//  Created by Waqar Malik on 5/27/21.
//

import Foundation

struct CHOrganization: Codable, Identifiable, Hashable {
	let id: String
	let name: String
	let image: URL?

	private enum CodingKeys: String, CodingKey {
		case id = "healthcareProviderTenantID"
		case name
		case image
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
