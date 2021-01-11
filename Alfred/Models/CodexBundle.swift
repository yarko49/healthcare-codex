//
//  BundleModel.swift
//  Alfred
//

import Foundation

// MARK: - BundleModel

struct CodexBundle: Codable {
	let entry: [BundleEntry]?
	let link: [BundleLink]?
	let resourceType: String?
	let total: Int?
	let type: String?
}

// MARK: - Entry

struct BundleEntry: Codable {
	let fullURL: String?
	let resource: CodexResource?
	let request: BundleRequest?
	let search: BundleSearch?
	let response: BundleResponse?

	enum CodingKeys: String, CodingKey {
		case fullURL = "fullUrl"
		case resource, search, request, response
	}
}

// MARK: - Search

struct BundleSearch: Codable {
	let mode: String?
}

// MARK: - Link

struct BundleLink: Codable {
	let relation: String?
	let url: String?
}

// MARK: - BERequest

struct BundleRequest: Codable {
	let method, url: String?
}

// MARK: - Response

struct BundleResponse: Codable {
	let etag, lastModified: String?
	let location: String?
	let status: String?
}
