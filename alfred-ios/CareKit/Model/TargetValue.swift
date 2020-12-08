//
//  TargetValue.swift
//  alfred-ios
//
//  Created by Waqar Malik on 12/6/20.
//

import Foundation

public enum ValueType: String, Codable, Hashable {
	case boolean
	case integer
	case string
	case unknown
}

public struct TargetValue: Codable, Hashable {
	public let id: String?
	public let index: Int
	public let remoteId: String?
	public let units: String?
	public let source: String?
	public let value: String
	public let type: ValueType
	public let groupId: String?
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
		case groupId = "groupIdentifier"
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
		if let valueString = try container.decodeIfPresent(String.self, forKey: .type), let valueType = ValueType(rawValue: valueString) {
			self.type = valueType
			switch valueType {
			case .boolean:
				let value = try container.decode(Bool.self, forKey: .value)
				self.value = "\(value)"
			case .integer:
				let value = try container.decode(Int.self, forKey: .value)
				self.value = "\(value)"
			case .string:
				self.value = try container.decode(String.self, forKey: .value)
			case .unknown:
				self.value = ""
			}
		} else {
			self.type = .unknown
			self.value = ""
		}
		self.groupId = try container.decodeIfPresent(String.self, forKey: .groupId)
		self.timezone = try container.decodeTimeZone(forKey: .timezone)
		self.effectiveDate = try container.decodeIfPresent(Date.self, forKey: .effectiveDate)
		self.kind = try container.decodeIfPresent(String.self, forKey: .kind)
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(id, forKey: .id)
		try container.encode(index, forKey: .index)
		try container.encodeIfPresent(remoteId, forKey: .remoteId)
		try container.encodeIfPresent(units, forKey: .units)
		try container.encodeIfPresent(source, forKey: .source)
		try container.encode(type, forKey: .type)
		switch type {
		case .boolean:
			let boolValue = Bool(value) ?? false
			try container.encode(boolValue, forKey: .value)
		case .integer:
			let intValue = Int(value) ?? 0
			try container.encode(intValue, forKey: .value)
		case .string:
			try container.encode(value, forKey: .value)
		case .unknown:
			break
		}
		try container.encodeIfPresent(groupId, forKey: .groupId)
		try container.encode(timezone.secondsFromGMT(), forKey: .timezone)
		try container.encodeIfPresent(effectiveDate, forKey: .effectiveDate)
		try container.encodeIfPresent(kind, forKey: .kind)
	}
}
