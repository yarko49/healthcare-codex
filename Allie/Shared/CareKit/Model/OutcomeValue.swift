//
//  TargetValue.swift
//  Allie
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
}

public struct OutcomeValue: Codable {
	public var index: Int
	public var units: String?
	public var value: OCKOutcomeValueUnderlyingType
	public var type: OCKOutcomeValueType
	public var createdDate: Date
	public var kind: String?

	public init(_ value: OCKOutcomeValueUnderlyingType, units: String? = nil) {
		self.index = 0
		self.value = value
		self.units = units
		self.createdDate = Date()
		if value is Int { self.type = .integer } else
		if value is Double { self.type = .double } else
		if value is String { self.type = .text } else
		if value is Bool { self.type = .boolean } else
		if value is Data { self.type = .binary } else
		if value is Date { self.type = .date } else {
			self.type = .binary
		}
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.index = try container.decodeIfPresent(Int.self, forKey: .index) ?? 0
		self.units = try container.decodeIfPresent(String.self, forKey: .units)
		let date = try container.decodeIfPresent(Date.self, forKey: .createdDate) ?? Date()
		self.createdDate = Calendar.current.startOfDay(for: date)
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
		try container.encode(index, forKey: .index)
		try container.encodeIfPresent(units, forKey: .units)
		try container.encode(type, forKey: .type)
		try container.encodeIfPresent(createdDate, forKey: .createdDate)
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

	private enum CodingKeys: String, CodingKey {
		case index
		case units
		case value
		case type
		case createdDate = "effectiveDate"
		case kind
	}
}
