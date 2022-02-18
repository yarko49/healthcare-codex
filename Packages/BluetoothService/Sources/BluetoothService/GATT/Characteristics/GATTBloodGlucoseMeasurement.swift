//
//  GATTBloodGlucoseMeasurement.swift
//
//
//  Created by Waqar Malik on 2/3/22.
//

import CoreBluetooth
import Foundation

@frozen
public struct GATTBloodGlucoseMeasurement: GATTCharacteristic {
	public static var rawIdentifier: Int { 0x2A18 }

	internal static let length = MemoryLayout<UInt16>.size

	public let data: Data

	public init?(data: Data) {
		guard data.count >= type(of: self).length else {
			return nil
		}

		self.data = data
	}

	public var description: String {
		"Blood Glucose Measurement"
	}

	public enum ConcentrationUnit: String, Hashable, CaseIterable {
		case mole = "mol/L"
		case kg = "kg/L"
	}

	public enum SampleType: String, Hashable, CaseIterable {
		case capillaryWholeBlood
		case controlSolution
		case other

		public init(measurement: Int) {
			if measurement == 1 {
				self = .capillaryWholeBlood
			} else if measurement == 10 {
				self = .controlSolution
			} else {
				self = .other
			}
		}
	}

	public struct SensorFlags: OptionSet, Hashable {
		public static let deviceBatteryLowTrue = SensorFlags(rawValue: 1)
		public static let sensorMalfunction = SensorFlags(rawValue: 1 << 1)
		public static let sampleSizeInsufficient = SensorFlags(rawValue: 1 << 2)
		public static let stripInsertionError = SensorFlags(rawValue: 1 << 3)
		public static let incorrectStrip = SensorFlags(rawValue: 1 << 4)
		public static let resultTooHighForDevice = SensorFlags(rawValue: 1 << 5)
		public static let resultTooLowForDevice = SensorFlags(rawValue: 1 << 6)
		public static let tempTooHigh = SensorFlags(rawValue: 1 << 7)
		public static let tempTooLow = SensorFlags(rawValue: 1 << 8)
		public static let readInterrupted = SensorFlags(rawValue: 1 << 9)
		public static let generalDeviceFault = SensorFlags(rawValue: 1 << 10)
		public static let timeFault = SensorFlags(rawValue: 1 << 11)
		public static let reserved = SensorFlags(rawValue: 1 << 12)

		public let rawValue: Int16

		public init(rawValue: Int16) {
			self.rawValue = rawValue
		}
	}
}

extension GATTBloodGlucoseMeasurement.SampleType: CustomStringConvertible {
	public var description: String {
		switch self {
		case .capillaryWholeBlood:
			return "Capillary Whole Blood"
		case .controlSolution:
			return "Control Solution"
		case .other:
			return"Other"
		}
	}
}
