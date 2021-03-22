//
//  Patient.swift
//  Allie
//
//  Created by Waqar Malik on 12/6/20.
//

import CareKitStore
import Foundation

public typealias AlliePatients = [AlliePatient]

public struct AlliePatient: Codable, Identifiable, OCKAnyPatient {
	public let id: String
	public var name: PersonNameComponents
	public var sex: OCKBiologicalSex?
	public var birthday: Date?
	public var allergies: [String]?

	public var effectiveDate: Date
	public var createdDate: Date?
	public var updatedDate: Date?

	public var groupIdentifier: String? // shared, active, inactive
	public var tags: [String]?
	public var remoteID: String?
	public var source: String?
	public var userInfo: [String: String]?
	public var asset: String?
	public var timezone: TimeZone
	public var notes: [OCKNote]?

	init(id: String, name: PersonNameComponents) {
		self.id = id
		self.name = name
		self.timezone = TimeZone.current
		self.effectiveDate = Calendar.current.startOfDay(for: Date())
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		self.id = try container.decode(String.self, forKey: .id)
		self.name = try container.decode(PersonNameComponents.self, forKey: .name)
		self.sex = try container.decodeIfPresent(OCKBiologicalSex.self, forKey: .sex)
		self.birthday = try container.decodeIfPresent(Date.self, forKey: .birthday)
		self.allergies = try container.decodeIfPresent([String].self, forKey: .allergies)

		self.effectiveDate = try container.decode(Date.self, forKey: .effectiveDate)
		self.createdDate = try container.decodeIfPresent(Date.self, forKey: .createdDate)
		self.updatedDate = try container.decodeIfPresent(Date.self, forKey: .updatedDate)
		self.groupIdentifier = try container.decodeIfPresent(String.self, forKey: .groupIdentifier)
		self.tags = try container.decodeIfPresent([String].self, forKey: .tags)
		self.remoteID = try container.decodeIfPresent(String.self, forKey: .remoteID)
		self.source = try container.decodeIfPresent(String.self, forKey: .source)
		let userInfo = try container.decodeIfPresent([String: AnyPrimitiveValue].self, forKey: .userInfo)
		let mapped = userInfo?.compactMapValues { (value) -> String? in
			value.stringValue
		}
		self.userInfo = mapped
		self.asset = try container.decodeIfPresent(String.self, forKey: .asset)
		self.timezone = try container.decodeTimeZone(forKey: .timezone)
		if remoteID == nil {
			self.remoteID = FHIRId
		}
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
		try container.encode(name, forKey: .name)
		try container.encodeIfPresent(sex, forKey: .sex)
		try container.encodeIfPresent(birthday, forKey: .birthday)
		try container.encodeIfPresent(allergies, forKey: .allergies)

		try container.encode(effectiveDate, forKey: .effectiveDate)
		try container.encodeIfPresent(createdDate, forKey: .createdDate)
		try container.encodeIfPresent(updatedDate, forKey: .updatedDate)
		try container.encodeIfPresent(groupIdentifier, forKey: .groupIdentifier)
		try container.encodeIfPresent(tags, forKey: .tags)
		try container.encodeIfPresent(remoteID, forKey: .remoteID)
		try container.encodeIfPresent(source, forKey: .source)
		try container.encodeIfPresent(userInfo, forKey: .userInfo)
		try container.encodeIfPresent(asset, forKey: .asset)
		try container.encode(timezone.secondsFromGMT(), forKey: .timezone)
	}

	private enum CodingKeys: String, CodingKey {
		case id
		case name
		case sex
		case birthday
		case allergies
		case effectiveDate
		case createdDate
		case updatedDate
		case groupIdentifier
		case tags
		case remoteID
		case source
		case userInfo
		case asset
		case notes
		case timezone
	}
}

extension AlliePatient: AnyPatientExtensible {}
