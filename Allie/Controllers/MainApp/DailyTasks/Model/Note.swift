//
//  PatientNote.swift
//  Allie
//
//  Created by Waqar Malik on 12/6/20.
//

import Foundation

public struct Note: Codable, Hashable {
	public let id: String?
	public var author: String?
	public var title: String?
	public var content: String?
	public var createDate: Date?
	public var updatedDate: Date?
	public var groupIdentifier: String?
	public var tags: [String]?
	public var remoteId: String?
	public var userInfo: [String: String]?
	public var source: String?
	public var asset: String?
	public var notes: [Note]?
	public var timezone: TimeZone
	public var effectiveDate: Date?

	init(id: String? = nil, timezone: TimeZone = .current) {
		self.id = id
		self.timezone = timezone
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decodeIfPresent(String.self, forKey: .id)
		self.author = try container.decodeIfPresent(String.self, forKey: .author)
		self.title = try container.decodeIfPresent(String.self, forKey: .title)
		self.content = try container.decodeIfPresent(String.self, forKey: .content)
		self.createDate = try container.decodeIfPresent(Date.self, forKey: .createDate)
		self.updatedDate = try container.decodeIfPresent(Date.self, forKey: .updatedDate)
		self.groupIdentifier = try container.decodeIfPresent(String.self, forKey: .groupIdentifier)
		self.tags = try container.decodeIfPresent([String].self, forKey: .tags)
		self.remoteId = try container.decodeIfPresent(String.self, forKey: .remoteId)
		self.userInfo = try container.decodeIfPresent([String: String].self, forKey: .userInfo)
		self.source = try container.decodeIfPresent(String.self, forKey: .source)
		self.asset = try container.decodeIfPresent(String.self, forKey: .asset)
		self.notes = try container.decodeIfPresent([Note].self, forKey: .notes)
		self.timezone = try container.decodeTimeZone(forKey: .timezone)
		self.effectiveDate = try container.decodeIfPresent(Date.self, forKey: .effectiveDate)
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(id, forKey: .id)
		try container.encodeIfPresent(author, forKey: .author)
		try container.encodeIfPresent(title, forKey: .title)
		try container.encodeIfPresent(content, forKey: .content)
		try container.encodeIfPresent(createDate, forKey: .createDate)
		try container.encodeIfPresent(updatedDate, forKey: .updatedDate)
		try container.encodeIfPresent(groupIdentifier, forKey: .groupIdentifier)
		try container.encodeIfPresent(tags, forKey: .tags)
		try container.encodeIfPresent(remoteId, forKey: .remoteId)
		try container.encodeIfPresent(userInfo, forKey: .userInfo)
		try container.encodeIfPresent(source, forKey: .source)
		try container.encodeIfPresent(asset, forKey: .asset)
		try container.encodeIfPresent(notes, forKey: .notes)
		try container.encodeIfPresent(timezone.secondsFromGMT(), forKey: .timezone)
		try container.encodeIfPresent(effectiveDate, forKey: .effectiveDate)
	}

	private enum CodingKeys: String, CodingKey {
		case id
		case author
		case title
		case content
		case createDate
		case updatedDate
		case groupIdentifier
		case tags
		case remoteId
		case userInfo
		case source
		case asset
		case notes
		case timezone
		case effectiveDate
	}
}
