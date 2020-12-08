//
//  PatientNote.swift
//  alfred-ios
//
//  Created by Waqar Malik on 12/6/20.
//

import Foundation

public struct Note: Codable {
	public let author: String
	public let title: String
	public let content: String
	public let remoteId: String
	public let groupIdentifier: String
	public let timezone: TimeZone
	public let id: String?
	public let source: String?
	public let asset: String?
	public let effectiveDate: Date?

	private enum CodingKeys: String, CodingKey {
		case author
		case title
		case content
		case remoteId
		case groupIdentifier
		case timezone
		case id
		case source
		case asset
		case effectiveDate
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.author = try container.decode(String.self, forKey: .author)
		self.title = try container.decode(String.self, forKey: .title)
		self.content = try container.decode(String.self, forKey: .content)
		self.remoteId = try container.decode(String.self, forKey: .remoteId)
		self.groupIdentifier = try container.decode(String.self, forKey: .groupIdentifier)
		self.timezone = try container.decodeTimeZone(forKey: .timezone)
		self.id = try container.decodeIfPresent(String.self, forKey: .id)
		self.source = try container.decodeIfPresent(String.self, forKey: .source)
		self.asset = try container.decodeIfPresent(String.self, forKey: .asset)
		self.effectiveDate = try container.decodeIfPresent(Date.self, forKey: .effectiveDate)
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(author, forKey: .author)
		try container.encode(title, forKey: .title)
		try container.encode(content, forKey: .content)
		try container.encode(remoteId, forKey: .remoteId)
		try container.encode(groupIdentifier, forKey: .groupIdentifier)
		try container.encode(timezone.secondsFromGMT(), forKey: .timezone)
		try container.encodeIfPresent(id, forKey: .id)
		try container.encodeIfPresent(source, forKey: .source)
		try container.encodeIfPresent(asset, forKey: .asset)
		try container.encodeIfPresent(effectiveDate, forKey: .effectiveDate)
	}
}
