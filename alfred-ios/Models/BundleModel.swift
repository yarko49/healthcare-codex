//
//  BundleModel.swift
//  alfred-ios
//

import Foundation

// MARK: - BundleModel

struct BundleModel: Codable {
	let entry: [Entry]?
	let link: [Link]?
	let resourceType: String?
	let total: Int?
	let type: String?
}

// MARK: - Entry

struct Entry: Codable {
	let fullURL: String?
	let resource: Resource?
	let request: Request?
	let search: Search?
	let response: Response?

	enum CodingKeys: String, CodingKey {
		case fullURL = "fullUrl"
		case resource, search, request, response
	}
}

// MARK: - Search

struct Search: Codable {
	let mode: String?
}

// MARK: - Link

struct Link: Codable {
	let relation: String?
	let url: String?
}

// MARK: - Request

struct Request: Codable {
	let method, url: String?
}

// MARK: - Response

struct Response: Codable {
	let etag, lastModified: String?
	let location: String?
	let status: String?
}
