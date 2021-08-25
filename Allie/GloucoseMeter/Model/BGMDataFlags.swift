//
//  BGMDataFlags.swift
//  Allie
//
//  Created by Waqar Malik on 7/27/21.
//

import Foundation

struct BGMDataFlags: OptionSet {
	let rawValue: Int16

	static let deviceBatteryLowTrue = BGMDataFlags(rawValue: 1)
	static let sensorMalfunction = BGMDataFlags(rawValue: 1 << 1)
	static let sampleSizeInsufficient = BGMDataFlags(rawValue: 1 << 2)
	static let stripInsertionError = BGMDataFlags(rawValue: 1 << 3)
	static let incorrectStrip = BGMDataFlags(rawValue: 1 << 4)
	static let resultTooHighForDevice = BGMDataFlags(rawValue: 1 << 5)
	static let resultTooLowForDevice = BGMDataFlags(rawValue: 1 << 6)
	static let tempTooHigh = BGMDataFlags(rawValue: 1 << 7)
	static let tempTooLow = BGMDataFlags(rawValue: 1 << 8)
	static let readInterrupted = BGMDataFlags(rawValue: 1 << 9)
	static let generalDeviceFault = BGMDataFlags(rawValue: 1 << 10)
	static let timeFault = BGMDataFlags(rawValue: 1 << 11)
	static let reserved = BGMDataFlags(rawValue: 1 << 12)
}
