//
//  GATTBloodPressureFeature.swift
//
//
//  Created by Waqar Malik on 2/3/22.
//

import CoreBluetooth
import Foundation

@frozen
public struct GATTBloodPressureFeature: GATTCharacteristic {
	public static var rawIdentifier: Int { 0x2A49 }
	internal static let length = MemoryLayout<UInt16>.size

	public let data: Data
	public let features: Feature

	public init?(data: Data) {
		guard data.count >= type(of: self).length else {
			return nil
		}

		self.data = data
		let values = [UInt8](data)
		self.features = Feature(rawValue: values[0])
	}

	public struct Feature: OptionSet, Equatable {
		public static let bodyMovement = Feature(rawValue: 1 << 1)
		public static let cuttFit = Feature(rawValue: 1 << 2)
		public static let irregularPulse = Feature(rawValue: 1 << 3)
		public static let pulseRateRange = Feature(rawValue: 1 << 4)
		public static let measurementPosition = Feature(rawValue: 1 << 5)
		public static let multipleBond = Feature(rawValue: 1 << 6)

		public let rawValue: UInt8

		public init(rawValue: UInt8) {
			self.rawValue = rawValue
		}
	}

	public var description: String {
		"Blood Pressure Feature"
	}
}
