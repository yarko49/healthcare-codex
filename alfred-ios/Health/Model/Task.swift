//
//  Task.swift
//  alfred-ios
//
//  Created by Waqar Malik on 12/6/20.
//

import Foundation

public typealias Tasks = [String: Task]

public struct Task: Codable, Hashable, Identifiable {
	public var carePlanId: String?
	public let id: String
	public var title: String?
	public var instructions: String?
	public var impactsAdherence: Bool = true
	public var schedules: [String: ScheduleElement]?
	public var groupIdentifier: String?
	public var tags: [String]?
	public var effectiveDate: Date
	public var createDate: Date?
	public var updatedDate: Date?
	public var remoteId: String?
	public var source: String?
	public var userInfo: [String: String]?
	public var asset: String?
	public var notes: [String: Note]?
	public var timezone: TimeZone

	public init(id: String, title: String?, carePlanUUID: String?) {
		self.id = id
		self.title = title
		self.carePlanId = carePlanUUID
		self.timezone = TimeZone.current
		self.effectiveDate = Date()
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.carePlanId = try container.decodeIfPresent(String.self, forKey: .carePlanId)
		self.id = try container.decode(String.self, forKey: .id)
		self.title = try container.decodeIfPresent(String.self, forKey: .title)
		self.instructions = try container.decodeIfPresent(String.self, forKey: .instructions)
		self.impactsAdherence = try container.decode(Bool.self, forKey: .impactsAdherence)
		self.schedules = try container.decodeIfPresent([String: ScheduleElement].self, forKey: .schedules)
		self.groupIdentifier = try container.decodeIfPresent(String.self, forKey: .groupIdentifier)
		self.tags = try container.decodeIfPresent([String].self, forKey: .tags)
		self.effectiveDate = try container.decode(Date.self, forKey: .effectiveDate)
		self.createDate = try container.decodeIfPresent(Date.self, forKey: .createDate)
		self.updatedDate = try container.decodeIfPresent(Date.self, forKey: .updatedDate)
		self.remoteId = try container.decodeIfPresent(String.self, forKey: .remoteId)
		self.source = try container.decodeIfPresent(String.self, forKey: .source)
		self.userInfo = try container.decodeIfPresent([String: String].self, forKey: .userInfo)
		self.asset = try container.decodeIfPresent(String.self, forKey: .asset)
		self.notes = try container.decodeIfPresent([String: Note].self, forKey: .notes)
		self.timezone = try container.decodeTimeZone(forKey: .timezone)
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(carePlanId, forKey: .carePlanId)
		try container.encode(id, forKey: .id)
		try container.encodeIfPresent(title, forKey: .title)
		try container.encodeIfPresent(instructions, forKey: .instructions)
		try container.encode(impactsAdherence, forKey: .impactsAdherence)
		try container.encodeIfPresent(schedules, forKey: .schedules)
		try container.encodeIfPresent(groupIdentifier, forKey: .groupIdentifier)
		try container.encodeIfPresent(tags, forKey: .tags)
		try container.encode(effectiveDate, forKey: .effectiveDate)
		try container.encodeIfPresent(createDate, forKey: .createDate)
		try container.encodeIfPresent(updatedDate, forKey: .updatedDate)
		try container.encodeIfPresent(remoteId, forKey: .remoteId)
		try container.encodeIfPresent(source, forKey: .source)
		try container.encode(userInfo, forKey: .userInfo)
		try container.encodeIfPresent(asset, forKey: .asset)
		try container.encodeIfPresent(notes, forKey: .notes)
		try container.encode(timezone.secondsFromGMT(), forKey: .timezone)
	}

	private enum CodingKeys: String, CodingKey {
		case carePlanId
		case id
		case title
		case instructions
		case impactsAdherence
		case schedules
		case groupIdentifier
		case tags
		case effectiveDate
		case createDate
		case updatedDate
		case remoteId
		case source
		case userInfo
		case asset
		case notes
		case timezone
	}
}
