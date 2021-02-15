//
//  CarePlan.swift
//  Allie
//
//  Created by Waqar Malik on 12/6/20.
//

import Foundation

public typealias CarePlans = [String: CarePlan]

public struct CarePlan: Codable, Identifiable {
	public let id: String
	public let title: String
	public let patientId: String
	public let remoteId: String?
	public let groupIdentifier: String?
	public let timezone: TimeZone
	public let effectiveDate: Date
	public let asset: String?
	public let tags: [String]?
	public let source: String?
	public let userInfo: [String: String]?
	public let notes: [String: Note]?
	public let tasks: Tasks?

	private enum CodingKeys: String, CodingKey {
		case id
		case title
		case patientId
		case remoteId
		case groupIdentifier
		case timezone
		case effectiveDate
		case asset
		case tags
		case source
		case userInfo
		case notes
		case tasks
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let theId = try container.decode(String.self, forKey: .id)
		self.remoteId = try container.decodeIfPresent(String.self, forKey: .remoteId) ?? UUID().uuidString
		self.id = theId.isEmpty ? remoteId ?? UUID().uuidString : theId
		self.title = try container.decode(String.self, forKey: .title)
		self.patientId = try container.decode(String.self, forKey: .patientId)
		self.groupIdentifier = try container.decode(String.self, forKey: .groupIdentifier)
		self.timezone = try container.decodeTimeZone(forKey: .timezone)
		let date = try container.decodeIfPresent(Date.self, forKey: .effectiveDate) ?? Date()
		self.effectiveDate = Calendar.current.startOfDay(for: date)
		self.asset = try container.decodeIfPresent(String.self, forKey: .asset)
		self.tags = try container.decodeIfPresent([String].self, forKey: .tags)
		self.source = try container.decodeIfPresent(String.self, forKey: .source)
		self.userInfo = try container.decodeIfPresent([String: String].self, forKey: .userInfo)
		self.notes = try container.decodeIfPresent([String: Note].self, forKey: .notes)
		let keyedTasks = try container.decodeIfPresent(Tasks.self, forKey: .tasks) ?? [:]
		var updatedTasks: Tasks = [:]
		for (key, value) in keyedTasks {
			var copy = value
			copy.id = key
			updatedTasks[key] = copy
		}
		self.tasks = updatedTasks
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
		try container.encode(title, forKey: .title)
		try container.encode(patientId, forKey: .patientId)
		try container.encode(remoteId, forKey: .remoteId)
		try container.encode(groupIdentifier, forKey: .groupIdentifier)
		try container.encode(timezone.secondsFromGMT(), forKey: .timezone)
		try container.encode(effectiveDate, forKey: .effectiveDate)
		try container.encodeIfPresent(asset, forKey: .asset)
		try container.encodeIfPresent(tags, forKey: .tags)
		try container.encodeIfPresent(source, forKey: .source)
		try container.encodeIfPresent(userInfo, forKey: .userInfo)
		try container.encodeIfPresent(notes, forKey: .notes)
		try container.encodeIfPresent(tasks, forKey: .tasks)
	}
}
