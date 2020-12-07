//
//  Patient.swift
//  alfred-ios
//
//  Created by Waqar Malik on 12/6/20.
//

import Foundation

public struct Patient: Codable, Hashable {
	public let id: String
	public let groupId: String
	public let name: PatientName
	public let remoteId: String
	public let createdAt: Date
	public var updatedAt: Date
	public let effectiveDate: Date
	public let birthday: Date
	public let timezone: TimeZone
	public var asset: String?
	public var tags: [String]?
	public var source: String?
	public let userInfo: [String: String]?

	private enum CodingKeys: String, CodingKey {
		case id
		case groupId = "groupIdentifier"
		case name
		case remoteId
		case createdAt = "createdDate"
		case updatedAt = "updatedDate"
		case effectiveDate
		case birthday
		case timezone
		case asset
		case tags
		case source
		case userInfo
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(String.self, forKey: .id)
		self.groupId = try container.decode(String.self, forKey: .groupId)
		self.name = try container.decode(PatientName.self, forKey: .name)
		self.remoteId = try container.decode(String.self, forKey: .remoteId)
		self.createdAt = try container.decodeDate(forKey: .createdAt)
		self.updatedAt = try container.decodeDate(forKey: .updatedAt)
		self.effectiveDate = try container.decodeDate(forKey: .effectiveDate)
		self.birthday = try container.decodeDate(forKey: .birthday)
		self.timezone = try container.decodeTimeZone(forKey: .timezone)
		self.asset = try container.decodeIfPresent(String.self, forKey: .asset)
		self.tags = try container.decodeIfPresent([String].self, forKey: .tags)
		self.source = try container.decodeIfPresent(String.self, forKey: .source)
		self.userInfo = try container.decodeIfPresent([String: String].self, forKey: .userInfo)
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
		try container.encode(groupId, forKey: .groupId)
		try container.encode(remoteId, forKey: .remoteId)
		try container.encode(createdAt, forKey: .createdAt)
		try container.encode(updatedAt, forKey: .updatedAt)
		try container.encode(effectiveDate, forKey: .effectiveDate)
		try container.encode(birthday, forKey: .birthday)
		try container.encode(timezone.secondsFromGMT(), forKey: .timezone)
		try container.encode(name, forKey: .name)
		try container.encodeIfPresent(asset, forKey: .asset)
		try container.encodeIfPresent(tags, forKey: .tags)
		try container.encodeIfPresent(source, forKey: .source)
		try container.encodeIfPresent(userInfo, forKey: .userInfo)
	}
}

public struct PatientName: Codable, Hashable {
	public var givenName: String
	public var familyName: String
	public var prefix: String?
	public var nameSuffix: String?
	public var middleName: String?
	public var nickName: String?
}
