//
//  CodeModel.swift
//  Allie
//

import Foundation

// MARK: - MedicalCoding

struct MedicalCode: Codable {
	let coding: [Coding]?

	struct Coding: Codable {
		let system: String?
		let code: String?
		let display: String?
	}
}
