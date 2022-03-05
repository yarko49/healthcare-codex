//
//  AnyPrimitiveValue.swift
//  Allie
//
//  Created by Waqar Malik on 3/7/21.
//

import Foundation

struct CHAnyPrimitiveValue: Codable {
	private var int: Int?
	private var string: String?
	private var bool: Bool?
	private var double: Double?

	init(_ int: Int) {
		self.int = int
	}

	init(_ string: String) {
		self.string = string
	}

	init(_ bool: Bool) {
		self.bool = bool
	}

	init(_ double: Double) {
		self.double = double
	}

	init(from decoder: Decoder) throws {
		if let int = try? decoder.singleValueContainer().decode(Int.self) {
			self.int = int
			return
		}

		if let string = try? decoder.singleValueContainer().decode(String.self) {
			self.string = string
			return
		}

		if let bool = try? decoder.singleValueContainer().decode(Bool.self) {
			self.bool = bool
			return
		}

		if let double = try? decoder.singleValueContainer().decode(Double.self) {
			self.double = double
		}
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()

		if let anyValue = value {
			if let value = anyValue as? Int {
				try container.encode(value)
				return
			}

			if let value = anyValue as? String {
				try container.encode(value)
				return
			}

			if let value = anyValue as? Bool {
				try container.encode(value)
				return
			}

			if let value = anyValue as? Double {
				try container.encode(value)
				return
			}
		}
		try container.encodeNil()
	}

	var value: Any? {
		int ?? string ?? bool ?? double
	}

	var stringValue: String? {
		if let stringValue = string {
			return stringValue
		} else if let boolValue = bool {
			return String(boolValue)
		} else if let intValue = int {
			return String(intValue)
		} else if let doubleValue = double {
			return String(doubleValue)
		} else {
			return nil
		}
	}
}
