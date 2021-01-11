//
//  ObservationBE.swift
//  Alfred
//

import Foundation

// MARK: - Resource

struct CodexResource: Codable {
	let id: String?
	let code: Code?
	let effectiveDateTime: String?
	let identifier: [Identifier]?
	let meta: Meta?
	let resourceType: String?
	let status: String?
	let subject: Subject?
	let valueQuantity: ValueQuantity?
	let birthDate: String?
	let gender: String?
	let name: [ResourceName]?
	let component: [Component]?
}

// MARK: - Component

struct Component: Codable {
	let code: Code?
	let valueQuantity: ValueQuantity?
}

// MARK: - Name

struct ResourceName: Codable {
	let use: String?
	let family: String?
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
