//
//  Outcome.swift
//  Allie
//
//  Created by Waqar Malik on 4/6/21.
//

import CareKitStore
import Foundation

public struct Outcome: Codable, Identifiable, Equatable {
	public let id: UUID
	public let taskID: String
	public let carePlanID: String
	public var groupIdentifier: String?
	public var remoteID: String?
	public var notes: [OCKNote]?
	public var asset: String?
	public var source: String?
	public var tags: [String]?
	public var timezone: TimeZone
	public var userInfo: [String: String]?
	public var createdDate: Date
	public var deletedDate: Date?
	public var effectiveDate: Date
	public var updatedDate: Date?
	public let taskOccurrenceIndex: Int
	public let values: [OCKOutcomeValue]

	private enum CodingKeys: String, CodingKey {
		case id
		case taskID = "taskId"
		case carePlanID = "carePlanId"
		case groupIdentifier
		case remoteID = "remoteId"
		case notes
		case asset
		case source
		case tags
		case timezone
		case userInfo
		case createdDate
		case deletedDate
		case effectiveDate
		case updatedDate
		case taskOccurrenceIndex
		case values
	}

	init(id: UUID, taskID: String, carePlanID: String, taskOccurrenceIndex: Int, values: [OCKOutcomeValue]) {
		self.id = id
		self.taskID = taskID
		self.carePlanID = carePlanID
		self.taskOccurrenceIndex = taskOccurrenceIndex
		self.values = values
		self.createdDate = Date()
		self.effectiveDate = Date()
		self.timezone = .current
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
		self.remoteID = try container.decodeIfPresent(String.self, forKey: .remoteID) ?? ""
		self.taskID = try container.decodeIfPresent(String.self, forKey: .taskID) ?? ""
		self.carePlanID = try container.decodeIfPresent(String.self, forKey: .carePlanID) ?? ""
		self.taskOccurrenceIndex = try container.decodeIfPresent(Int.self, forKey: .taskOccurrenceIndex) ?? 0
		self.values = try container.decodeIfPresent([OCKOutcomeValue].self, forKey: .values) ?? []
		self.createdDate = try container.decodeIfPresent(Date.self, forKey: .createdDate) ?? Date()
		self.effectiveDate = try container.decodeIfPresent(Date.self, forKey: .effectiveDate) ?? Date()
		self.updatedDate = try container.decodeIfPresent(Date.self, forKey: .updatedDate)
		self.deletedDate = try container.decodeIfPresent(Date.self, forKey: .deletedDate)
		self.timezone = try container.decodeTimeZone(forKey: .timezone)
		self.notes = try container.decodeIfPresent([OCKNote].self, forKey: .notes)
		self.groupIdentifier = try container.decodeIfPresent(String.self, forKey: .groupIdentifier)
		self.asset = try container.decodeIfPresent(String.self, forKey: .asset)
		self.source = try container.decodeIfPresent(String.self, forKey: .source)
		self.tags = try container.decodeIfPresent([String].self, forKey: .tags)
		self.userInfo = try container.decodeIfPresent([String: String].self, forKey: .userInfo)
	}
}
