//
//  CarePlan.swift
//  alfred-ios
//
//  Created by Waqar Malik on 12/6/20.
//

import Foundation

public struct CarePlan: Codable, Hashable {
	public let id: String
	public let title: String
	public let patientId: String
	public let remoteId: String
	public let groupId: String
	public let timezone: TimeZone
	public let effectiveDate: Date
	public let asset: String?
	public let tags: [String]?
	public let source: String?
	public let userInfo: [String: String]?
	public let notes: [String: Note]?

	private enum CodingKeys: String, CodingKey {
		case id
		case title
		case patientId
		case remoteId
		case groupId = "groupIdentifier"
		case timezone
		case effectiveDate
		case asset
		case tags
		case source
		case userInfo
		case notes
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(String.self, forKey: .id)
		self.title = try container.decode(String.self, forKey: .title)
		self.patientId = try container.decode(String.self, forKey: .patientId)
		self.remoteId = try container.decode(String.self, forKey: .remoteId)
		self.groupId = try container.decode(String.self, forKey: .groupId)
		self.timezone = try container.decodeTimeZone(forKey: .timezone)
		self.effectiveDate = try container.decodeDate(forKey: .effectiveDate)
		self.asset = try container.decodeIfPresent(String.self, forKey: .asset)
		self.tags = try container.decodeIfPresent([String].self, forKey: .tags)
		self.source = try container.decodeIfPresent(String.self, forKey: .source)
		self.userInfo = try container.decodeIfPresent([String: String].self, forKey: .userInfo)
		self.notes = try container.decodeIfPresent([String: Note].self, forKey: .notes)
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
		try container.encode(title, forKey: .title)
		try container.encode(patientId, forKey: .patientId)
		try container.encode(remoteId, forKey: .remoteId)
		try container.encode(groupId, forKey: .groupId)
		try container.encode(timezone.secondsFromGMT(), forKey: .timezone)
		try container.encode(effectiveDate, forKey: .effectiveDate)
		try container.encodeIfPresent(asset, forKey: .asset)
		try container.encodeIfPresent(tags, forKey: .tags)
		try container.encodeIfPresent(source, forKey: .source)
		try container.encodeIfPresent(userInfo, forKey: .userInfo)
		try container.encodeIfPresent(notes, forKey: .notes)
	}
}
