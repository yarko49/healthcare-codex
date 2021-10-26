//
//  CHOutcome.swift
//  Allie
//
//  Created by Waqar Malik on 4/6/21.
//

import CareKitStore
import Foundation
import HealthKit

struct CHOutcome: Codable, Identifiable, AnyItemDeletable, AnyUserInfoExtensible {
	var uuid: UUID
	let taskUUID: UUID
	let taskId: String
	let carePlanId: String
	var carePlanUUID: UUID?
	var groupIdentifier: String?
	var remoteId: String?
	var notes: [OCKNote]?
	var asset: String?
	var source: String?
	var tags: [String]?
	var timezone: TimeZone
	var userInfo: [String: String]?
	var createdDate: Date
	var deletedDate: Date?
	var effectiveDate: Date
	var updatedDate: Date?
	let taskOccurrenceIndex: Int
	var values: [CHOutcomeValue]
	var startDate: Date?
	var endDate: Date?
	var device: CHDevice?
	var sourceRevision: CHSourceRevision?
	var provenance: CHProvenance?
	var isBluetoothCollected: Bool
	var healthKit: HealthKit?

	struct HealthKit: Codable {
		var quantityIdentifier: String
		var sampleUUID: UUID
	}

	private enum CodingKeys: String, CodingKey {
		case uuid = "id"
		case taskId
		case taskUUID = "taskLocalId"
		case carePlanId
		case carePlanUUID = "carePlanLocalId"
		case groupIdentifier
		case remoteId
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
		case startDate
		case endDate
		case device
		case sourceRevision
		case provenance
		case isBluetoothCollected = "bluetoothCollected"
		case healthKit
	}

	var id: String { taskUUID.uuidString + "_\(taskOccurrenceIndex)" }

	init(taskUUID: UUID, taskID: String, carePlanID: String, taskOccurrenceIndex: Int, values: [CHOutcomeValue]) {
		self.uuid = UUID()
		self.taskUUID = taskUUID
		self.taskId = taskID
		self.carePlanId = carePlanID
		self.taskOccurrenceIndex = taskOccurrenceIndex
		self.values = values
		self.createdDate = Date()
		self.effectiveDate = Date()
		self.timezone = .current
		self.isBluetoothCollected = false
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.uuid = try container.decodeIfPresent(UUID.self, forKey: .uuid) ?? UUID()
		self.taskUUID = try container.decodeIfPresent(UUID.self, forKey: .taskUUID) ?? UUID()
		self.remoteId = try container.decodeIfPresent(String.self, forKey: .remoteId)
		self.taskId = try container.decodeIfPresent(String.self, forKey: .taskId) ?? ""
		self.carePlanId = try container.decodeIfPresent(String.self, forKey: .carePlanId) ?? ""
		if let uuidString = try container.decodeIfPresent(String.self, forKey: .carePlanUUID), let uuid = UUID(uuidString: uuidString) {
			self.carePlanUUID = uuid
		}
		self.taskOccurrenceIndex = try container.decodeIfPresent(Int.self, forKey: .taskOccurrenceIndex) ?? 0
		self.values = try container.decodeIfPresent([CHOutcomeValue].self, forKey: .values) ?? []
		self.createdDate = try container.decodeIfPresent(Date.self, forKey: .createdDate) ?? Date()
		self.effectiveDate = try container.decodeIfPresent(Date.self, forKey: .effectiveDate) ?? createdDate
		self.updatedDate = try container.decodeIfPresent(Date.self, forKey: .updatedDate)
		self.deletedDate = try container.decodeIfPresent(Date.self, forKey: .deletedDate)
		self.timezone = (try? container.decode(TimeZone.self, forKey: .timezone)) ?? .current
		self.notes = try container.decodeIfPresent([OCKNote].self, forKey: .notes)
		self.groupIdentifier = try container.decodeIfPresent(String.self, forKey: .groupIdentifier)
		self.asset = try container.decodeIfPresent(String.self, forKey: .asset)
		self.source = try container.decodeIfPresent(String.self, forKey: .source)
		self.tags = try container.decodeIfPresent([String].self, forKey: .tags)
		self.userInfo = try container.decodeIfPresent([String: String].self, forKey: .userInfo)
		self.startDate = try container.decodeIfPresent(Date.self, forKey: .startDate)
		self.endDate = try container.decodeIfPresent(Date.self, forKey: .endDate)
		self.device = try container.decodeIfPresent(CHDevice.self, forKey: .device)
		self.sourceRevision = try container.decodeIfPresent(CHSourceRevision.self, forKey: .sourceRevision)
		self.isBluetoothCollected = try container.decodeIfPresent(Bool.self, forKey: .isBluetoothCollected) ?? false
		self.provenance = try container.decodeIfPresent(CHProvenance.self, forKey: .provenance)
		self.healthKit = try container.decodeIfPresent(HealthKit.self, forKey: .healthKit)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(uuid, forKey: .uuid)
		try container.encode(taskUUID, forKey: .taskUUID)
		try container.encode(taskId, forKey: .taskId)
		try container.encode(carePlanId, forKey: .carePlanId)
		try container.encode(carePlanUUID, forKey: .carePlanUUID)
		try container.encodeIfPresent(groupIdentifier, forKey: .groupIdentifier)
		try container.encodeIfPresent(remoteId, forKey: .remoteId)
		try container.encodeIfPresent(notes, forKey: .notes)
		try container.encodeIfPresent(asset, forKey: .asset)
		try container.encodeIfPresent(source, forKey: .source)
		try container.encodeIfPresent(tags, forKey: .tags)
		try container.encode(timezone, forKey: .timezone)
		try container.encodeIfPresent(userInfo, forKey: .userInfo)
		try container.encodeIfPresent(createdDate, forKey: .createdDate)
		try container.encodeIfPresent(deletedDate, forKey: .deletedDate)
		try container.encodeIfPresent(effectiveDate, forKey: .effectiveDate)
		try container.encodeIfPresent(updatedDate, forKey: .updatedDate)
		try container.encode(taskOccurrenceIndex, forKey: .taskOccurrenceIndex)
		try container.encode(values, forKey: .values)
		try container.encodeIfPresent(startDate, forKey: .startDate)
		try container.encodeIfPresent(endDate, forKey: .endDate)
		try container.encodeIfPresent(device, forKey: .device)
		try container.encodeIfPresent(sourceRevision, forKey: .sourceRevision)
		try container.encode(isBluetoothCollected, forKey: .isBluetoothCollected)
		try container.encodeIfPresent(provenance, forKey: .provenance)
		try container.encodeIfPresent(healthKit, forKey: .healthKit)
	}
}
