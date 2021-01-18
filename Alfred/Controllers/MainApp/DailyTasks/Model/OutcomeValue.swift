//
//  TargetValue.swift
//  Alfred
//
//  Created by Waqar Malik on 12/6/20.
//

import CareKitStore
import Foundation

public extension OCKOutcomeValueUnderlyingType {
	func isEqual(rhs: OCKOutcomeValueUnderlyingType) -> Bool {
		if let lvalue = self as? Int, let rvalue = rhs as? Int {
			return lvalue == rvalue
		} else if let lvalue = self as? Double, let rvalue = rhs as? Double {
			return lvalue == rvalue
		} else if let lvalue = self as? Bool, let rvalue = rhs as? Bool {
			return lvalue == rvalue
		} else if let lvalue = self as? String, let rvalue = rhs as? String {
			return lvalue == rvalue
		} else if let lvalue = self as? Data, let rvalue = rhs as? Data {
			return lvalue == rvalue
		} else if let lvalue = self as? Date, let rvalue = rhs as? Date {
			return lvalue == rvalue
		}
		return false
	}

	func hash(into hasher: inout Hasher) {
		if let value = self as? Int {
			hasher.combine(value)
		} else if let value = self as? Double {
			hasher.combine(value)
		} else if let value = self as? Bool {
			hasher.combine(value)
		} else if let value = self as? String {
			hasher.combine(value)
		} else if let value = self as? Data {
			hasher.combine(value)
		} else if let value = self as? Date {
			hasher.combine(value)
		}
	}

	// swiftlint:disable:next legacy_hashing
	var hashValue: Int {
		if let value = self as? Int {
			return value.hashValue
		} else if let value = self as? Double {
			return value.hashValue
		} else if let value = self as? Bool {
			return value.hashValue
		} else if let value = self as? String {
			return value.hashValue
		} else if let value = self as? Data {
			return value.hashValue
		} else if let value = self as? Date {
			return value.hashValue
		}
		return 0
	}
}

public struct OutcomeValue: Codable, Hashable {
	public var id: String?
	public var index: Int
	public var remoteId: String?
	public var units: String?
	public var source: String?
	public var value: OCKOutcomeValueUnderlyingType
	public var type: OCKOutcomeValueType
	public var groupIdentifier: String?
	public var timezone: TimeZone
	public var effectiveDate: Date
	public var kind: String?
	public var tags: [String]?
	public var userInfo: [String: String]?
	public var asset: String?
	public var notes: [Note]?

	public init(_ value: OCKOutcomeValueUnderlyingType, units: String? = nil) {
		self.value = value
		self.units = units
		self.timezone = TimeZone.current
		self.effectiveDate = Calendar.current.startOfDay(for: Date())
		if value is Int { self.type = .integer } else
		if value is Double { self.type = .double } else
		if value is String { self.type = .text } else
		if value is Bool { self.type = .boolean } else
		if value is Data { self.type = .binary } else
		if value is Date { self.type = .date } else {
			self.type = .binary
		}
		self.index = 0
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decodeIfPresent(String.self, forKey: .id)
		self.index = try container.decodeIfPresent(Int.self, forKey: .index) ?? 0
		self.remoteId = try container.decodeIfPresent(String.self, forKey: .remoteId)
		self.units = try container.decodeIfPresent(String.self, forKey: .units)
		self.source = try container.decodeIfPresent(String.self, forKey: .source)
		self.groupIdentifier = try container.decodeIfPresent(String.self, forKey: .groupIdentifier)
		self.timezone = try container.decodeTimeZone(forKey: .timezone)
		let date = try container.decodeIfPresent(Date.self, forKey: .effectiveDate) ?? Date()
		self.effectiveDate = Calendar.current.startOfDay(for: date)
		self.kind = try container.decodeIfPresent(String.self, forKey: .kind)
		self.tags = try container.decodeIfPresent([String].self, forKey: .tags)
		self.userInfo = try container.decodeIfPresent([String: String].self, forKey: .userInfo)
		self.asset = try container.decodeIfPresent(String.self, forKey: .asset)
		self.notes = try container.decodeIfPresent([Note].self, forKey: .notes)
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
		try container.encodeIfPresent(index, forKey: .index)
		try container.encodeIfPresent(remoteId, forKey: .remoteId)
		try container.encodeIfPresent(units, forKey: .units)
		try container.encodeIfPresent(source, forKey: .source)
		try container.encode(type, forKey: .type)
		try container.encodeIfPresent(groupIdentifier, forKey: .groupIdentifier)
		try container.encode(timezone.secondsFromGMT(), forKey: .timezone)
		try container.encodeIfPresent(effectiveDate, forKey: .effectiveDate)
		try container.encodeIfPresent(kind, forKey: .kind)
		try container.encodeIfPresent(tags, forKey: .tags)
		try container.encodeIfPresent(userInfo, forKey: .userInfo)
		try container.encodeIfPresent(asset, forKey: .asset)
		try container.encodeIfPresent(notes, forKey: .notes)

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

	public static func == (lhs: OutcomeValue, rhs: OutcomeValue) -> Bool {
		lhs.id == rhs.id &&
			lhs.index == rhs.index &&
			lhs.remoteId == rhs.remoteId &&
			lhs.units == rhs.units &&
			lhs.source == rhs.source &&
			lhs.type == rhs.type &&
			lhs.groupIdentifier == rhs.groupIdentifier &&
			lhs.timezone == rhs.timezone &&
			lhs.effectiveDate == rhs.effectiveDate &&
			lhs.kind == rhs.kind &&
			lhs.value.isEqual(rhs: rhs.value)
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(index)
		hasher.combine(type)
		hasher.combine(timezone)
		hasher.combine(value.hashValue)
		if let value = id {
			hasher.combine(value)
		}
		if let value = remoteId {
			hasher.combine(value)
		}
		if let value = units {
			hasher.combine(value)
		}
		if let value = source {
			hasher.combine(value)
		}
		if let value = groupIdentifier {
			hasher.combine(value)
		}
		hasher.combine(effectiveDate)
		if let value = kind {
			hasher.combine(value)
		}
	}

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
		case tags
		case userInfo
		case asset
		case notes
	}
}
