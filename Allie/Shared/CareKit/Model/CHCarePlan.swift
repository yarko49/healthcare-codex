//
//  CHCarePlan.swift
//  Allie
//
//  Created by Waqar Malik on 12/6/20.
//

import CareKitStore
import Foundation

public typealias CHCarePlans = [CHCarePlan]

public struct CHCarePlan: Codable, Identifiable, AnyItemDeletable {
	public var id: String
	public var uuid: UUID?
	public var title: String
	public var patientId: String?
	public var remoteId: String?
	public var groupIdentifier: String?
	public var timezone: TimeZone
	public var effectiveDate: Date
	public var deletedDate: Date?
	public var asset: String?
	public var tags: [String]?
	public var source: String?
	public var userInfo: [String: String]?
	public var createdDate: Date?
	public var updatedDate: Date?

	private enum CodingKeys: String, CodingKey {
		case id
		case uuid
		case title
		case patientId
		case remoteId
		case groupIdentifier
		case timezone
		case effectiveDate
		case deletedDate
		case asset
		case tags
		case source
		case userInfo
		case notes
		case tasks
		case createdDate
		case updatedDate
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(String.self, forKey: .id)
		self.uuid = try container.decodeIfPresent(UUID.self, forKey: .uuid)
		self.remoteId = try container.decodeIfPresent(String.self, forKey: .remoteId)
		self.title = try container.decode(String.self, forKey: .title)
		self.patientId = try container.decodeIfPresent(String.self, forKey: .patientId)
		self.groupIdentifier = try container.decode(String.self, forKey: .groupIdentifier)
		self.timezone = (try? container.decode(TimeZone.self, forKey: .timezone)) ?? .current
		let date = try container.decodeIfPresent(Date.self, forKey: .effectiveDate) ?? Date()
		self.effectiveDate = Calendar.current.startOfDay(for: date)
		self.deletedDate = try container.decodeIfPresent(Date.self, forKey: .deletedDate)
		self.asset = try container.decodeIfPresent(String.self, forKey: .asset)
		self.tags = try container.decodeIfPresent([String].self, forKey: .tags)
		self.source = try container.decodeIfPresent(String.self, forKey: .source)
		self.userInfo = try container.decodeIfPresent([String: String].self, forKey: .userInfo)
		self.createdDate = try container.decodeIfPresent(Date.self, forKey: .createdDate)
		self.updatedDate = try container.decodeIfPresent(Date.self, forKey: .updatedDate)
		if id.isEmpty {
			self.id = remoteId ?? ""
		}
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
		try container.encodeIfPresent(uuid, forKey: .uuid)
		try container.encode(title, forKey: .title)
		try container.encodeIfPresent(patientId, forKey: .patientId)
		try container.encode(remoteId, forKey: .remoteId)
		try container.encode(groupIdentifier, forKey: .groupIdentifier)
		try container.encode(timezone, forKey: .timezone)
		try container.encode(effectiveDate, forKey: .effectiveDate)
		try container.encodeIfPresent(deletedDate, forKey: .deletedDate)
		try container.encodeIfPresent(asset, forKey: .asset)
		try container.encodeIfPresent(tags, forKey: .tags)
		try container.encodeIfPresent(source, forKey: .source)
		try container.encodeIfPresent(userInfo, forKey: .userInfo)
		try container.encodeIfPresent(createdDate, forKey: .createdDate)
		try container.encodeIfPresent(updatedDate, forKey: .updatedDate)
	}
}
