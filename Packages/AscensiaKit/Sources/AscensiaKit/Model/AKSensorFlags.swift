//
//  BGMDataFlags.swift
//  Allie
//
//  Created by Waqar Malik on 7/27/21.
//

import Foundation

public struct AKSensorFlags: OptionSet, Hashable {
	public static let deviceBatteryLowTrue = AKSensorFlags(rawValue: 1)
	public static let sensorMalfunction = AKSensorFlags(rawValue: 1 << 1)
	public static let sampleSizeInsufficient = AKSensorFlags(rawValue: 1 << 2)
	public static let stripInsertionError = AKSensorFlags(rawValue: 1 << 3)
	public static let incorrectStrip = AKSensorFlags(rawValue: 1 << 4)
	public static let resultTooHighForDevice = AKSensorFlags(rawValue: 1 << 5)
	public static let resultTooLowForDevice = AKSensorFlags(rawValue: 1 << 6)
	public static let tempTooHigh = AKSensorFlags(rawValue: 1 << 7)
	public static let tempTooLow = AKSensorFlags(rawValue: 1 << 8)
	public static let readInterrupted = AKSensorFlags(rawValue: 1 << 9)
	public static let generalDeviceFault = AKSensorFlags(rawValue: 1 << 10)
	public static let timeFault = AKSensorFlags(rawValue: 1 << 11)
	public static let reserved = AKSensorFlags(rawValue: 1 << 12)

	public let rawValue: Int16

	public init(rawValue: Int16) {
		self.rawValue = rawValue
	}
}
