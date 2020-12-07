//
//  Task.swift
//  alfred-ios
//
//  Created by Waqar Malik on 12/6/20.
//

import Foundation

public struct Task: Codable, Hashable {
	public let id: String
	public let remoteId: String
	public let title: String
	public let carePlanId: String
	public let groupId: String
	public let timezone: TimeZone
	public let effectiveDate: Date
	public let instructions: String
	public let impactsAdherence: Bool
	public let asset: String?
	public let source: String?
	public let schedules: [String: Schedule]

	private enum CodingKeys: String, CodingKey {
		case id
		case remoteId
		case title
		case carePlanId
		case groupId = "groupIdentifier"
		case timezone
		case effectiveDate
		case instructions
		case impactsAdherence
		case asset
		case source
		case schedules
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(String.self, forKey: .id)
		self.remoteId = try container.decode(String.self, forKey: .remoteId)
		self.title = try container.decode(String.self, forKey: .title)
		self.carePlanId = try container.decode(String.self, forKey: .carePlanId)
		self.groupId = try container.decode(String.self, forKey: .groupId)
		self.timezone = try container.decodeTimeZone(forKey: .timezone)
		self.effectiveDate = try container.decodeDate(forKey: .effectiveDate)
		self.instructions = try container.decode(String.self, forKey: .instructions)
		self.impactsAdherence = try container.decode(Bool.self, forKey: .impactsAdherence)
		self.asset = try container.decodeIfPresent(String.self, forKey: .asset)
		self.source = try container.decodeIfPresent(String.self, forKey: .source)
		self.schedules = try container.decode([String: Schedule].self, forKey: .schedules)
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
		try container.encode(remoteId, forKey: .remoteId)
		try container.encode(title, forKey: .title)
		try container.encode(carePlanId, forKey: .carePlanId)
		try container.encode(groupId, forKey: .groupId)
		try container.encode(timezone.secondsFromGMT(), forKey: .timezone)
		try container.encode(effectiveDate, forKey: .effectiveDate)
		try container.encode(instructions, forKey: .instructions)
		try container.encode(impactsAdherence, forKey: .impactsAdherence)
		try container.encodeIfPresent(asset, forKey: .asset)
		try container.encodeIfPresent(source, forKey: .source)
		try container.encode(schedules, forKey: .schedules)
	}
}
