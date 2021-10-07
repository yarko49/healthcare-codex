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

public struct CHOutcomeValue: Codable, Equatable {
	public static func == (lhs: CHOutcomeValue, rhs: CHOutcomeValue) -> Bool {
		lhs.hasSameValueAs(rhs) &&
			lhs.type == rhs.type &&
			lhs.kind == rhs.kind
	}

	public var index: Int = 0

	public var value: OCKOutcomeValueUnderlyingType

	/// The value was entered by user
	public var wasUserEntered: Bool = false

	/// UUID unique id of the object in healthKtt
	public var healthKitUUID: UUID?

	/// A HealthKitQuantityIdentifier that describes the outcome's data type.
	public var quantityIdentifier: String?

	/// An optional property that can be used to specify what kind of value this is (e.g. blood pressure, qualitative stress, weight)
	public var kind: String?

	/// The units for this measurement.
	public var units: String?

	/// The date that this value was created.
	public var createdDate = Date()

	/// Holds information about the type of this value.
	public var type: OCKOutcomeValueType {
		if value is Int { return .integer }
		if value is Double { return .double }
		if value is Bool { return .boolean }
		if value is String { return .text }
		if value is Data { return .binary }
		if value is Date { return .date }
		fatalError("Unknown type!")
	}

	public var description: String {
		switch type {
		// swiftlint:disable:next force_cast
		case .integer: return "\(value as! Int)"
		// swiftlint:disable:next force_cast
		case .double: return "\(value as! Double)"
		// swiftlint:disable:next force_cast
		case .boolean: return "\(value as! Bool)"
		// swiftlint:disable:next force_cast
		case .text: return "\(value as! String)"
		// swiftlint:disable:next force_cast
		case .binary: return "\(value as! Data)"
		// swiftlint:disable:next force_cast
		case .date: return "\(value as! Date)"
		}
	}

	/// Checks if two `OCKOutcomeValue`s have equal value properties, without checking their other properties.
	private func hasSameValueAs(_ other: CHOutcomeValue) -> Bool {
		switch type {
		case .binary: return dataValue == other.dataValue
		case .boolean: return booleanValue == other.booleanValue
		case .date: return dateValue == other.dateValue
		case .double: return doubleValue == other.doubleValue
		case .integer: return integerValue == other.integerValue
		case .text: return stringValue == other.stringValue
		}
	}

	// The value as an `NSNumber`. This property can be useful when comparing outcome values with an underlying
	// type of Bool, Double, or Int against one another.
	public var numberValue: NSNumber? {
		switch type {
		case .boolean: return NSNumber(value: booleanValue!)
		case .double: return NSNumber(value: doubleValue!)
		case .integer: return NSNumber(value: integerValue!)
		default: return nil
		}
	}

	public init(_ value: OCKOutcomeValueUnderlyingType, units: String? = nil) {
		self.value = value
		self.units = units
	}

	public var integerValue: Int? { value as? Int }

	/// The underlying value as a floating point number.
	public var doubleValue: Double? { value as? Double }

	/// The underlying value as a boolean.
	public var booleanValue: Bool? { value as? Bool }

	/// The underlying value as text.
	public var stringValue: String? { value as? String }

	/// The underlying value as binary data.
	public var dataValue: Data? { value as? Data }

	/// The underlying value as a date.
	public var dateValue: Date? { value as? Date }

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.index = try container.decodeIfPresent(Int.self, forKey: .index) ?? 0
		self.units = try container.decodeIfPresent(String.self, forKey: .units)
		let date = try container.decodeIfPresent(Date.self, forKey: .createdDate) ?? Date()
		self.createdDate = Calendar.current.startOfDay(for: date)
		self.kind = try container.decodeIfPresent(String.self, forKey: .kind)
		let valueType = try container.decode(OCKOutcomeValueType.self, forKey: .type)
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
		case createdDate
		case kind
	}
}
