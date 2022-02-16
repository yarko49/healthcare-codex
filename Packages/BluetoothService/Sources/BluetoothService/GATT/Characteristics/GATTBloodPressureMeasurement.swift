//
//  GATTBloodPressureMeasurement.swift
//
//
//  Created by Waqar Malik on 2/3/22.
//

import CoreBluetooth
import Foundation

@frozen
public struct GATTBloodPressureMeasurement: GATTCharacteristic {
	public static var rawIdentifier: Int { 0x2A35 }

	internal static let length: Int = 12

	public let data: Data
	public let flags: Flags
	public let systolic: Float16
	public let diastolic: Float16
	public let meanArterialPressure: Float16
	public let unit: Unit

	/// Time Stamp
	public var timestamp: GATTDateTime?

	/// Pulse Rate
	public var pulseRate: Float16?

	/// User ID
	public var userIdentifier: UInt8?

	/// Measurement Status
	public var measurementStatus: MeasurementStatus?

	public init?(data: Data) {
		self.data = data
		let values = [UInt8](data)
		self.flags = Flags(rawValue: values[0])
		self.unit = flags.contains(.bloodPressureUnits) ? .kPa : .mmHg

		self.systolic = Float16(UInt16(littleEndian: UInt16(bytes: (values[1], values[2]))))
		self.diastolic = Float16(UInt16(littleEndian: UInt16(bytes: (values[3], values[4]))))
		self.meanArterialPressure = Float16(UInt16(littleEndian: UInt16(bytes: (values[5], values[6]))))
		var index = 6 // last accessed index

		if flags.contains(.timestamp) {
			guard index + GATTDateTime.length < data.count else {
				return nil
			}

			let timestampData = data.subdataNoCopy(in: index + 1 ..< index + 1 + GATTDateTime.length)
			assert(timestampData.count == GATTDateTime.length)

			guard let timestamp = GATTDateTime(data: timestampData) else {
				return nil
			}
			self.timestamp = timestamp
			index += GATTDateTime.length
		} else {
			self.timestamp = nil
		}

		if flags.contains(.pulseRate) {
			guard index + MemoryLayout<UInt16>.size < data.count else {
				return nil
			}

			self.pulseRate = Float16(UInt16(littleEndian: UInt16(bytes: (data[index + 1], data[index + 2]))))
			index += MemoryLayout<UInt16>.size
		} else {
			self.pulseRate = nil
		}

		if flags.contains(.userId) {
			guard index + 1 < data.count else {
				return nil
			}
			self.userIdentifier = data[index + 1]
			index += 1
		} else {
			self.pulseRate = nil
		}

		if flags.contains(.measurementStatus) {
			guard index + 2 < data.count else {
				return nil
			}
			self.measurementStatus = MeasurementStatus(rawValue: UInt16(littleEndian: UInt16(bytes: (data[index + 1], data[index + 2]))))
			index += 2
		} else {
			self.measurementStatus = nil
		}
	}

	public enum Unit: UInt16, Hashable, CaseIterable {
		case mmHg = 0x2781
		case kPa = 0x2724
	}

	public struct Flags: OptionSet, Equatable {
		public static let bloodPressureUnits = Flags(rawValue: 1 << 1)
		public static let timestamp = Flags(rawValue: 1 << 2)
		public static let pulseRate = Flags(rawValue: 1 << 3)
		public static let userId = Flags(rawValue: 1 << 4)
		public static let measurementStatus = Flags(rawValue: 1 << 5)

		public let rawValue: UInt8

		public init(rawValue: UInt8) {
			self.rawValue = rawValue
		}
	}

	public struct MeasurementStatus: Equatable {
		public let rawValue: UInt16

		public let isBodyMovementStable: Bool
		public let didCuffFitProperly: Bool
		public let isPulseNormal: Bool
		public let pulseRateRange: Int
		public let isMeasurementPositionProper: Bool

		public init(rawValue: UInt16) {
			self.rawValue = rawValue

			self.isBodyMovementStable = (rawValue & 0b01) == 0
			self.didCuffFitProperly = (rawValue & 0b10) == 0
			self.isPulseNormal = (rawValue & 0b100) == 0
			self.pulseRateRange = Int(rawValue & 0b11000)
			self.isMeasurementPositionProper = (rawValue & 0b100000) == 0
		}
	}

	public var description: String {
		"Blood Pressure Measurement"
	}
}
