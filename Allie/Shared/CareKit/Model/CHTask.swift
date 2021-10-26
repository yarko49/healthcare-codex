//
//  AllieTask.swift
//  Allie
//
//  Created by Waqar Malik on 12/6/20.
//

import CareKitStore
import Foundation
import HealthKit

typealias CHTasks = [CHTask]

struct CHBasicTask: Codable {
	var id: String?
	var title: String?
	var carePlanId: String?
}

struct CHTask: Codable, Identifiable, AnyUserInfoExtensible, AnyItemDeletable {
	var carePlanId: String?
	var id: String
	var carePlanUUID: UUID?
	var title: String?
	var instructions: String?
	var impactsAdherence: Bool = true
	var scheduleElements: [CHScheduleElement]
	var groupIdentifier: String?
	var tags: [String]?
	var createdDate: Date
	var effectiveDate: Date
	var deletedDate: Date?
	var updatedDate: Date?
	var source: String?
	var userInfo: [String: String]?
	var asset: String?
	var notes: [OCKNote]?
	var timezone: TimeZone
	var healthKitLinkage: OCKHealthKitLinkage?
	var schedule: OCKSchedule
	var links: [CHLink]?

	var remoteId: String {
		id
	}

	init(id: String, title: String?, carePlanUUID: String?, schedule: OCKSchedule) {
		self.id = id
		self.title = title
		self.carePlanId = carePlanUUID
		self.timezone = TimeZone.current
		self.createdDate = Calendar.current.startOfDay(for: Date())
		self.effectiveDate = createdDate
		self.schedule = schedule
		self.scheduleElements = []
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.carePlanId = try container.decodeIfPresent(String.self, forKey: .carePlanId)
		self.id = try container.decode(String.self, forKey: .id)
		self.carePlanUUID = try container.decodeIfPresent(UUID.self, forKey: .carePlanUUID)
		self.title = try container.decodeIfPresent(String.self, forKey: .title)
		self.instructions = try container.decodeIfPresent(String.self, forKey: .instructions)
		self.impactsAdherence = try container.decode(Bool.self, forKey: .impactsAdherence)
		if let elements = try? container.decodeIfPresent([String: CHScheduleElement].self, forKey: .scheduleElements) {
			self.scheduleElements = Array(elements.values)
		} else if let elements = try? container.decodeIfPresent([CHScheduleElement].self, forKey: .scheduleElements) {
			self.scheduleElements = elements
		} else {
			let context = DecodingError.Context(codingPath: [CodingKeys.scheduleElements], debugDescription: "Missing Schedule id = \(id), id = \(String(describing: id)), title = \(String(describing: title))")
			throw DecodingError.valueNotFound([CHScheduleElement].self, context)
		}

		self.groupIdentifier = try container.decodeIfPresent(String.self, forKey: .groupIdentifier)
		self.tags = try container.decodeIfPresent([String].self, forKey: .tags)
		var date = try container.decodeIfPresent(Date.self, forKey: .createdDate) ?? Date()
		self.createdDate = Calendar.current.startOfDay(for: date)
		date = try container.decodeIfPresent(Date.self, forKey: .effectiveDate) ?? createdDate
		self.effectiveDate = Calendar.current.startOfDay(for: date)
		self.updatedDate = try container.decodeIfPresent(Date.self, forKey: .updatedDate)
		self.deletedDate = try container.decodeIfPresent(Date.self, forKey: .deletedDate)
		self.source = try container.decodeIfPresent(String.self, forKey: .source)
		self.userInfo = try container.decodeIfPresent([String: String].self, forKey: .userInfo)
		self.asset = try container.decodeIfPresent(String.self, forKey: .asset)
		if let notes = try? container.decodeIfPresent([String: OCKNote].self, forKey: .notes) {
			self.notes = Array(notes.values)
		} else if let notes = try? container.decodeIfPresent([OCKNote].self, forKey: .notes) {
			self.notes = notes
		}
		self.timezone = (try? container.decode(TimeZone.self, forKey: .timezone)) ?? .current
		let ockElements = scheduleElements.map { element -> OCKScheduleElement in
			OCKScheduleElement(scheduleElement: element)
		}
		self.schedule = OCKSchedule(composing: ockElements)
		if let linkage = try container.decodeIfPresent([String: String].self, forKey: .healthKitLinkage) {
			self.healthKitLinkage = OCKHealthKitLinkage(linkage: linkage)
			if asset == nil || asset == "" {
				self.asset = healthKitLinkage?.quantityIdentifier.assetName
			}
		}
		self.links = try container.decodeIfPresent([CHLink].self, forKey: .links)
	}

	func encode(to encoder: Encoder) throws {
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
		try container.encodeIfPresent(createdDate, forKey: .createdDate)
		try container.encodeIfPresent(updatedDate, forKey: .updatedDate)
		try container.encodeIfPresent(source, forKey: .source)
		try container.encode(userInfo, forKey: .userInfo)
		try container.encodeIfPresent(asset, forKey: .asset)
		try container.encodeIfPresent(notes, forKey: .notes)
		try container.encode(timezone, forKey: .timezone)
		try container.encodeIfPresent(healthKitLinkage, forKey: .healthKitLinkage)
		try container.encodeIfPresent(links, forKey: .links)
	}

	private enum CodingKeys: String, CodingKey {
		case carePlanId
		case id = "remoteId"
		case carePlanUUID
		case title
		case instructions
		case impactsAdherence
		case scheduleElements = "schedules"
		case groupIdentifier
		case tags
		case effectiveDate
		case createdDate
		case updatedDate
		case deletedDate
		case source
		case userInfo
		case asset
		case notes
		case timezone
		case healthKitLinkage
		case links
	}
}
