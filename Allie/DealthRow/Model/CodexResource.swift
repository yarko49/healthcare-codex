//
//  ObservationBE.swift
//  Allie
//

import Foundation

// MARK: - Resource

// ModelsR4.Observation
struct CodexResource: Codable {
	let id: String?
	let code: MedicalCode?
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

// ModelsR4.ObservationComponent
struct Component: Codable {
	let code: MedicalCode?
	let valueQuantity: ValueQuantity?
}

// MARK: - Name

struct ResourceName: Codable {
	let use: String?
	let family: String?
	let given: [String]?
}

// MARK: - ValueQuantity

// ModelsR4.Quantity
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
