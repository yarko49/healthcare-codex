//
//  Patient.swift
//  alfred-ios
//
//  Created by Waqar Malik on 12/6/20.
//

import CareKitStore
import Foundation

public typealias Patients = [String: Patient]

public struct Patient: Codable {
	public let id: String
	public let groupIdentifier: String
	public let name: PersonNameComponents
	public let remoteId: String
	public let createdDate: Date
	public var updatedDate: Date
	public let effectiveDate: Date
	public let birthday: Date
	public let timezone: TimeZone
	public var asset: String?
	public var tags: [String]?
	public var source: String?
	public let userInfo: [String: String]?

	private enum CodingKeys: String, CodingKey {
		case id
		case groupIdentifier
		case name
		case remoteId
		case createdDate
		case updatedDate
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
		self.groupIdentifier = try container.decode(String.self, forKey: .groupIdentifier)
		self.name = try container.decode(PersonNameComponents.self, forKey: .name)
		self.remoteId = try container.decode(String.self, forKey: .remoteId)
		self.createdDate = try container.decode(Date.self, forKey: .createdDate)
		self.updatedDate = try container.decode(Date.self, forKey: .updatedDate)
		self.effectiveDate = try container.decode(Date.self, forKey: .effectiveDate)
		self.birthday = try container.decode(Date.self, forKey: .birthday)
		self.timezone = try container.decodeTimeZone(forKey: .timezone)
		self.asset = try container.decodeIfPresent(String.self, forKey: .asset)
		self.tags = try container.decodeIfPresent([String].self, forKey: .tags)
		self.source = try container.decodeIfPresent(String.self, forKey: .source)
		self.userInfo = try container.decodeIfPresent([String: String].self, forKey: .userInfo)
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
		try container.encode(groupIdentifier, forKey: .groupIdentifier)
		try container.encode(remoteId, forKey: .remoteId)
		try container.encode(createdDate, forKey: .createdDate)
		try container.encode(updatedDate, forKey: .updatedDate)
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
