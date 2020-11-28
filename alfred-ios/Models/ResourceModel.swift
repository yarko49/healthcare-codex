//
//  ObservationBE.swift
//  alfred-ios
//

import Foundation

// MARK: - Resource

struct Resource: Codable {
	let code: Code?
	let effectiveDateTime, id: String?
	let identifier: [Identifier]?
	let meta: Meta?
	let resourceType, status: String?
	let subject: Subject?
	let valueQuantity: ValueQuantity?
	let birthDate, gender: String?
	let name: [Name]?
	let component: [Component]?
}

// MARK: - Component

struct Component: Codable {
	let code: Code?
	let valueQuantity: ValueQuantity?
}

// MARK: - Name

struct Name: Codable {
	let use, family: String?
	let given: [String]?
}

// MARK: - ValueQuantity

struct ValueQuantity: Codable {
	let value: Int?
	let unit: String?
}

// MARK: - Meta

struct Meta: Codable {
	let lastUpdated, versionID: String?

	enum CodingKeys: String, CodingKey {
		case lastUpdated
		case versionID = "versionId"
	}
}
