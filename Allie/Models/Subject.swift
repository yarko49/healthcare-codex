//
//  SubjectModel.swift
//  Allie
//

import Foundation

// MARK: - Subject

struct Subject: Codable {
	let reference: String?
	let type: String?
	let identifier: Identifier?
	let display: String?
}

// MARK: - Identifier

struct Identifier: Codable {
	let assigner: Assigner?
	let use: String?
	let type: TypeClass?
	let system: String?
	let value: String?
}

// MARK: - TypeClass

struct TypeClass: Codable {
	let text: String?
}

// MARK: - Assigner

struct Assigner: Codable {
	let reference: String?
}
