//
//  CodeModel.swift
//  alfred-ios
//

import Foundation

// MARK: - Code
struct Code: Codable {
    let coding: [Coding]?
}

// MARK: - Coding
struct Coding: Codable {
    let system: String?
    let code, display: String?
}
