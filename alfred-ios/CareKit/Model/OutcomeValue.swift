//
//  TargetValue.swift
//  alfred-ios
//
//  Created by Waqar Malik on 12/6/20.
//

import CareKitStore
import Foundation

public struct OutcomeValue: Codable {
	public let id: String?
	public let index: Int
	public let remoteId: String?
	public let units: String?
	public let source: String?
	public let value: OCKOutcomeValueUnderlyingType
	public let type: OCKOutcomeValueType
	public let groupIdentifier: String?
	public let timezone: TimeZone
	public let effectiveDate: Date?
	public let kind: String?

	private enum CodingKeys: String, CodingKey {
		case id
		case index
		case remoteId
		case units
		case source
		case value
		case type
		case groupIdentifier
		case timezone
		case effectiveDate
		case kind
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decodeIfPresent(String.self, forKey: .id)
		self.index = try container.decode(Int.self, forKey: .index)
		self.remoteId = try container.decodeIfPresent(String.self, forKey: .remoteId)
		self.units = try container.decodeIfPresent(String.self, forKey: .units)
		self.source = try container.decodeIfPresent(String.self, forKey: .source)
		self.groupIdentifier = try container.decodeIfPresent(String.self, forKey: .groupIdentifier)
		self.timezone = try container.decodeTimeZone(forKey: .timezone)
		self.effectiveDate = try container.decodeIfPresent(Date.self, forKey: .effectiveDate)
		self.kind = try container.decodeIfPresent(String.self, forKey: .kind)
		let valueType = try container.decode(OCKOutcomeValueType.self, forKey: .type)
		self.type = valueType
		switch valueType {
		case .integer:
			self.value = try container.decode(Int.self, forKey: .value)
		case .double:
			self.value = try container.decode(Double.self, forKey: .value)
		case .boolean:
			self.value = try container.decode(Bool.self, forKey: .value)
		case .text:
			self.value = try container.decode(String.self, forKey: .value)
		case .binary:
			self.value = try container.decode(Data.self, forKey: .value)
		case .date:
			self.value = try container.decode(Date.self, forKey: .value)
		}
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(id, forKey: .id)
		try container.encode(index, forKey: .index)
		try container.encodeIfPresent(remoteId, forKey: .remoteId)
		try container.encodeIfPresent(units, forKey: .units)
		try container.encodeIfPresent(source, forKey: .source)
		try container.encode(type, forKey: .type)
		try container.encodeIfPresent(groupIdentifier, forKey: .groupIdentifier)
		try container.encode(timezone.secondsFromGMT(), forKey: .timezone)
		try container.encodeIfPresent(effectiveDate, forKey: .effectiveDate)
		try container.encodeIfPresent(kind, forKey: .kind)

		var encodedValue = false
		if let value = value as? Int { try container.encode(value, forKey: .value); encodedValue = true } else
		if let value = value as? Double { try container.encode(value, forKey: .value); encodedValue = true } else
		if let value = value as? String { try container.encode(value, forKey: .value); encodedValue = true } else
		if let value = value as? Bool { try container.encode(value, forKey: .value); encodedValue = true } else
		if let value = value as? Data { try container.encode(value, forKey: .value); encodedValue = true } else
		if let value = value as? Date { try container.encode(value, forKey: .value); encodedValue = true }
		guard encodedValue else {
			let message = "Value could not be converted to a concrete type."
			throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: [CodingKeys.value], debugDescription: message))
		}
	}
}
