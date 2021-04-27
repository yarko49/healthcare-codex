//
//  Task.swift
//  Allie
//
//  Created by Waqar Malik on 12/6/20.
//

import CareKitStore
import Foundation
import HealthKit

public typealias Tasks = [Task]

public struct Task: Codable, Identifiable, AnyUserInfoExtensible {
	public var carePlanId: String?
	public var id: String
	public var carePlanUUID: UUID?
	public var title: String?
	public var instructions: String?
	public var impactsAdherence: Bool = true
	public var scheduleElements: [ScheduleElement]
	public var groupIdentifier: String?
	public var tags: [String]?
	public var effectiveDate: Date
	public var createDate: Date?
	public var updatedDate: Date?
	public var remoteId: String?
	public var source: String?
	public var userInfo: [String: String]?
	public var asset: String?
	public var notes: [OCKNote]?
	public var timezone: TimeZone
	public var healthKitLinkage: OCKHealthKitLinkage?
	public var schedule: OCKSchedule

	public init(id: String, title: String?, carePlanUUID: String?, schedule: OCKSchedule) {
		self.id = id
		self.title = title
		self.carePlanId = carePlanUUID
		self.timezone = TimeZone.current
		self.effectiveDate = Date()
		self.schedule = schedule
		self.scheduleElements = []
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.carePlanId = try container.decodeIfPresent(String.self, forKey: .carePlanId)
		self.remoteId = try container.decodeIfPresent(String.self, forKey: .remoteId)
		self.id = try container.decode(String.self, forKey: .id)
		if id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
			self.id = remoteId ?? ""
		}
		self.carePlanUUID = try container.decodeIfPresent(UUID.self, forKey: .carePlanUUID)
		self.title = try container.decodeIfPresent(String.self, forKey: .title)
		self.instructions = try container.decodeIfPresent(String.self, forKey: .instructions)
		self.impactsAdherence = try container.decode(Bool.self, forKey: .impactsAdherence)
		if let elements = try? container.decodeIfPresent([String: ScheduleElement].self, forKey: .scheduleElements) {
			self.scheduleElements = Array(elements.values)
		} else if let elements = try? container.decodeIfPresent([ScheduleElement].self, forKey: .scheduleElements) {
			self.scheduleElements = elements
		} else {
			self.scheduleElements = []
		}
		self.groupIdentifier = try container.decodeIfPresent(String.self, forKey: .groupIdentifier)
		self.tags = try container.decodeIfPresent([String].self, forKey: .tags)
		let date = try container.decodeIfPresent(Date.self, forKey: .effectiveDate) ?? Date()
		self.effectiveDate = Calendar.current.startOfDay(for: date)
		self.createDate = try container.decodeIfPresent(Date.self, forKey: .createDate)
		self.updatedDate = try container.decodeIfPresent(Date.self, forKey: .updatedDate)
		self.source = try container.decodeIfPresent(String.self, forKey: .source)
		self.userInfo = try container.decodeIfPresent([String: String].self, forKey: .userInfo)
		self.asset = try container.decodeIfPresent(String.self, forKey: .asset)
		if let notes = try? container.decodeIfPresent([String: OCKNote].self, forKey: .notes) {
			self.notes = Array(notes.values)
		} else if let notes = try? container.decodeIfPresent([OCKNote].self, forKey: .notes) {
			self.notes = notes
		}
		self.timezone = (try? container.decode(TimeZone.self, forKey: .timezone)) ?? .current
		self.schedule = OCKSchedule(composing: scheduleElements.map { element -> OCKScheduleElement in
			OCKScheduleElement(scheduleElement: element)
		})
		ALog.info("Start Date = \(schedule.startDate())")
		if let linkage = try container.decodeIfPresent(HealthKitLinkage.self, forKey: .healthKitLinkage) {
			self.healthKitLinkage = linkage.hkLinkage
			setUserInfo(string: linkage.identifier.rawValue, forKey: HealthKitLinkageKeys.identifierKey)
			setUserInfo(string: linkage.type.rawValue, forKey: HealthKitLinkageKeys.quantityTypeKey)
			setUserInfo(string: linkage.unit.rawValue, forKey: HealthKitLinkageKeys.unitKey)
		}
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(carePlanId, forKey: .carePlanId)
		try container.encode(id, forKey: .id)
		try container.encodeIfPresent(carePlanUUID, forKey: .carePlanUUID)
		try container.encodeIfPresent(title, forKey: .title)
		try container.encodeIfPresent(instructions, forKey: .instructions)
		try container.encode(impactsAdherence, forKey: .impactsAdherence)
		try container.encodeIfPresent(scheduleElements, forKey: .scheduleElements)
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
		try container.encode(timezone, forKey: .timezone)
		try container.encodeIfPresent(healthKitLinkage, forKey: .healthKitLinkage)
	}

	private enum CodingKeys: String, CodingKey {
		case carePlanId
		case id
		case carePlanUUID
		case title
		case instructions
		case impactsAdherence
		case scheduleElements = "schedules"
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
		case healthKitLinkage
	}
}
