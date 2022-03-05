//
//  CHCarePlan.swift
//  Allie
//
//  Created by Waqar Malik on 12/6/20.
//

import CareKitStore
import Foundation

public typealias CHCarePlans = [CHCarePlan]

public struct CHCarePlan: Codable, Identifiable, AnyItemDeletable, OCKAnyCarePlan, Equatable {
	/// The UUID of the patient to whom this care plan belongs.
	public var patientUUID: UUID?
	public var id: String
	public var uuid: UUID?
	public var title: String
	public var groupIdentifier: String?
	public var patientId: String?
	public var timezone: TimeZone
	public var createdDate: Date
	public var effectiveDate: Date
	public var deletedDate: Date?
	public var updatedDate: Date?
	public var asset: String?
	public var tags: [String]?
	public var source: String?
	public var userInfo: [String: String]?
	public var notes: [OCKNote]?
	public var remoteID: String? {
		id
	}

	private enum CodingKeys: String, CodingKey {
		case id = "remoteId"
		case uuid
		case title
		case patientId
		case groupIdentifier
		case timezone
		case createdDate
		case effectiveDate
		case deletedDate
		case updatedDate
		case asset
		case tags
		case source
		case userInfo
		case notes
		case tasks
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(String.self, forKey: .id)
		self.uuid = try container.decodeIfPresent(UUID.self, forKey: .uuid)
		self.title = try container.decode(String.self, forKey: .title)
		self.patientId = try container.decodeIfPresent(String.self, forKey: .patientId)
		self.timezone = (try? container.decode(TimeZone.self, forKey: .timezone)) ?? .current
		var date = try container.decodeIfPresent(Date.self, forKey: .createdDate) ?? Date()
		self.createdDate = Calendar.current.startOfDay(for: date)
		date = try container.decodeIfPresent(Date.self, forKey: .effectiveDate) ?? createdDate
		self.updatedDate = try container.decodeIfPresent(Date.self, forKey: .updatedDate)
		self.effectiveDate = Calendar.current.startOfDay(for: date)
		self.deletedDate = try container.decodeIfPresent(Date.self, forKey: .deletedDate)
		self.asset = try container.decodeIfPresent(String.self, forKey: .asset)
		self.tags = try container.decodeIfPresent([String].self, forKey: .tags)
		self.source = try container.decodeIfPresent(String.self, forKey: .source)
		self.userInfo = try container.decodeIfPresent([String: String].self, forKey: .userInfo)
		self.groupIdentifier = try container.decodeIfPresent(String.self, forKey: .groupIdentifier)
		self.notes = try container.decodeIfPresent([OCKNote].self, forKey: .notes)
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
		try container.encodeIfPresent(uuid, forKey: .uuid)
		try container.encode(title, forKey: .title)
		try container.encodeIfPresent(patientId, forKey: .patientId)
		try container.encode(timezone, forKey: .timezone)
		try container.encode(effectiveDate, forKey: .effectiveDate)
		try container.encodeIfPresent(deletedDate, forKey: .deletedDate)
		try container.encodeIfPresent(asset, forKey: .asset)
		try container.encodeIfPresent(tags, forKey: .tags)
		try container.encodeIfPresent(source, forKey: .source)
		try container.encodeIfPresent(userInfo, forKey: .userInfo)
		try container.encodeIfPresent(createdDate, forKey: .createdDate)
		try container.encodeIfPresent(updatedDate, forKey: .updatedDate)
		try container.encodeIfPresent(groupIdentifier, forKey: .groupIdentifier)
		try container.encodeIfPresent(notes, forKey: .notes)
	}

	public func belongs(to patient: OCKAnyPatient) -> Bool {
		guard let other = patient as? CHPatient else {
			return false
		}
		return patientUUID == other.uuid
	}

	public static func == (lhs: CHCarePlan, rhs: CHCarePlan) -> Bool {
		lhs.id == rhs.id
	}
}
