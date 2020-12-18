//
//  PatientModel.swift
//  alfred-ios

import FHIR
import Foundation

// MARK: - Welcome

struct PatientModel: Codable {
	let resourceType, birthDate, gender: String?
	let name: [Name]?
}

// MARK: - Name

struct Name: Codable {
	let use, family: String?
	let given: [String]?
}

// MARK: - PatientResponse

struct PatientResponse: Codable {
	let birthDate, gender, id: String?
	let identifier: [Identifier]?
	let meta: Meta?
	let name: [Name]?
	let resourceType: String?
}

// MARK: - Identifier

struct Identifier: Codable {
	let assigner: Assigner?
	let system, value: String?
}
