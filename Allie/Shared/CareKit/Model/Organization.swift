//
//  Organization.swift
//  Allie
//
//  Created by Waqar Malik on 5/27/21.
//

import Foundation

struct Organization: Codable, Identifiable, Hashable {
	let id: String
	let name: String
	let image: URL?
	let info: String?

	private enum CodingKeys: String, CodingKey {
		case id
		case name
		case image
		case info = "description"
	}
}

extension Organization: CustomStringConvertible {
	var description: String {
		info ?? name
	}
}

extension Organization: CustomDebugStringConvertible {
	var debugDescription: String {
		"{\n\tId = \(id)\n\tName = \(name)\n\tInfo = \(info ?? "")\n}"
	}
}
