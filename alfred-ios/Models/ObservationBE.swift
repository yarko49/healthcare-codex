//
//  ObservationBE.swift
//  alfred-ios
//

import Foundation
import FHIR

// MARK: - ObservationBE
struct ObservationBE: Codable {
    let resourceType, status: String?
    let subject: Subject?
    let effectiveDateTime: String?
    let code: Code?
    let valueQuantity: ValueQuantity?
}

// MARK: - Code
struct Code: Codable {
    let coding: [Coding]?
}

// MARK: - Coding
struct Coding: Codable {
    let system: String?
    let code, display: String?
}

// MARK: - Subject
struct Subject: Codable {
    let reference: String?
}

// MARK: - ValueQuantity
struct ValueQuantity: Codable {
    let value: Int?
    let unit: String?
}

import Foundation

// MARK: - ObservationResponse
struct ObservationResponse: Codable {
    let code: Code?
    let effectiveDateTime, id: String?
    let meta: Meta?
    let resourceType, status: String?
    let subject: Subject?
    let valueQuantity: ValueQuantity?
}

// MARK: - Meta
struct Meta: Codable {
    let lastUpdated, versionID: String?

    enum CodingKeys: String, CodingKey {
        case lastUpdated
        case versionID = "versionId"
    }
}
