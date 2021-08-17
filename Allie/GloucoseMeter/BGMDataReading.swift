//
//  BGMDataReading.swift
//  Allie
//
//  Created by Waqar Malik on 7/27/21.
//

import CoreBluetooth
import Foundation

struct BGMDataReading: Identifiable, Hashable {
	var peripheral: CBPeripheral?
	var measurement: [Int]
	var context: [Int]

	var id: UUID? {
		peripheral?.identifier
	}

	init(measurement: [Int], context: [Int], peripheral: CBPeripheral? = nil) {
		self.measurement = measurement
		self.context = context
		self.peripheral = peripheral
	}
}

extension BGMDataReading {
	var sequence: Int {
		(measurement[2] << 8) | measurement[1]
	}

	var timestamp: Date? {
		// First construct the UTC date from base time
		var components = DateComponents()
		components.day = measurement[6]
		components.month = measurement[5]
		components.year = ((measurement[4] << 8) | measurement[3])

		components.hour = measurement[7]
		components.minute = measurement[8]
		components.second = measurement[9]
		components.timeZone = TimeZone(identifier: "UTC")

		let UTCRecord = Calendar.current.date(from: components)
		return UTCRecord
	}

	var timezoneOffsetInSeconds: Int {
		// Figure out time offset between base time and user-facing time. Wants offset in seconds for HealthKit timezone metadata
		let value: Int = (measurement[11] << 8) | measurement[10]
		var mantissa: Int = (value & 0xFFF)
		mantissa = mantissa > 0x7FF ? -((~mantissa & 0xFFF) + 1) : mantissa // Decode 2's complement of 12-bit value if negative
		return mantissa * 60
	}

	var concentration: Double {
		// Figure out floating point glucose concentration
		let exp2c: Int = (measurement[13] >> 4) // Isolate the signed 4-bit exponent in MSB
		let exponent: Int = exp2c > 0x7 ? -((~exp2c & 0b1111) + 1) : exp2c // Decode 2's complement of 4-bit value if negative
		let mantissa = ((measurement[13] & 0b1111) << 8) | measurement[12]
		let glucose = Double(mantissa) * pow(10, Double(exponent))
		return glucose
	}

	var units: GlucoseConcentrationUnit {
		// Parse the Information Flags in Byte 0
		let flagByte = UInt8(measurement[0])
		let glucoseUnitsFlag: Bool = (flagByte & 0b100) == 1 ? true : false
		let glucoseUnits: GlucoseConcentrationUnit = (glucoseUnitsFlag == true) ? .mole : .kg
		return glucoseUnits
	}

	var location: String {
		switch measurement[14] >> 4 { // Sample Location
		case 15:
			return "Not available"
		default:
			return "Other"
		}
	}

	// These are the standard blood sample encodings from Bluetooth Glucose Service GATT
	var type: String {
		switch measurement[14] & 0b1111 { // Sample Location
		case 1:
			return "Capillary Whole blood"
		case 10:
			return "Control Solution"
		default:
			return "Other"
		}
	}

	// These are the standard meal encodings from Bluetooth Glucose Service GATT
	var mealContext: String {
		// check for meal context present
		var meal: String = ""
		guard !context.isEmpty else {
			return meal
		}
		if context[0] == 2 {
			let carbID = context[3]
			switch carbID {
			case 1:
				meal = "Preprandial"
			case 2:
				meal = "Postprandial"
			case 3:
				meal = "Fasting"
			case 4:
				meal = "Casual"
			case 5:
				meal = "Bedtime"
			default:
				meal = "Undefined"
			}
		}
		return meal
	}

	var mealTime: BGMMealTime {
		var mealTime: BGMMealTime = .undefined
		guard !context.isEmpty else {
			return mealTime
		}
		if context[0] == 2 {
			let carbID = context[3]
			mealTime = BGMMealTime(rawValue: carbID) ?? .undefined
		}

		return mealTime
	}
}
