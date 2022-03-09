//
//  BloodGlucoseReading.swift
//  Allie
//
//  Created by Waqar Malik on 7/27/21.
//

import CoreBluetooth
import Foundation

public struct BloodGlucoseReading: Identifiable, Hashable {
	public weak var peripheral: CBPeripheral?
	public var measurement: [Int]
	public var context: [Int]
	public var measurementData: Data // Data Encoding ascii
	public var contextData: Data? // Data Encoding ascii

	public var id: UUID? {
		peripheral?.identifier
	}

	public init(measurement: [Int], context: [Int], peripheral: CBPeripheral? = nil, measurementData: Data = Data(), contextData: Data? = nil) {
		self.measurement = measurement
		self.context = context
		self.peripheral = peripheral
		self.measurementData = measurementData
		self.contextData = contextData
	}

	public init(measurementData value: Data, contextData: Data? = nil, peripheral: CBPeripheral? = nil) {
		let valueArray = [UInt8](value)
		self.measurement = valueArray.map { byte in
			Int(byte)
		}
		self.context = []
		if let contextData = contextData {
			let contextArray = [UInt8](contextData)
			self.context = contextArray.map { byte in
				Int(byte)
			}
		}
		self.measurementData = value
		self.contextData = contextData
		self.peripheral = peripheral
	}
}

public extension BloodGlucoseReading {
	var sequence: Int {
		(measurement[2] << 8) | measurement[1]
	}

	var utcTimestamp: Date? {
		// First construct the UTC date from base time
		var components = DateComponents()
		components.day = measurement[6]
		components.month = measurement[5]
		components.year = ((measurement[4] << 8) | measurement[3])

		components.hour = measurement[7]
		components.minute = measurement[8]
		components.second = measurement[9]
		components.timeZone = TimeZone(identifier: "UTC")

		return Calendar.current.date(from: components)
	}

	var timezoneOffsetInSeconds: Int {
		// Figure out time offset between base time and user-facing time. Wants offset in seconds for HealthKit timezone metadata
		let value: Int = (measurement[11] << 8) | measurement[10]
		var mantissa: Int = (value & 0xFFF)
		mantissa = mantissa > 0x7FF ? -((~mantissa & 0xFFF) + 1) : mantissa // Decode 2's complement of 12-bit value if negative
		return mantissa * 60
	}

	var concentration: Double {
		// kg/L
		// Figure out floating point glucose concentration
		let exp2c: Int = (measurement[13] >> 4) // Isolate the signed 4-bit exponent in MSB
		let exponent: Int = exp2c > 0x7 ? -((~exp2c & 0b1111) + 1) : exp2c // Decode 2's complement of 4-bit value if negative
		let mantissa = ((measurement[13] & 0b1111) << 8) | measurement[12]
		let glucose = Double(mantissa) * pow(10, Double(exponent))
		return glucose
	}

	var units: GATTBloodGlucoseMeasurement.ConcentrationUnit {
		// Parse the Information Flags in Byte 0
		let flagByte = UInt8(measurement[0])
		let glucoseUnitsFlag: Bool = (flagByte & 0b100) == 1 ? true : false
		let glucoseUnits: GATTBloodGlucoseMeasurement.ConcentrationUnit = (glucoseUnitsFlag == true) ? .mole : .kg
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
		var meal = ""
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

	var mealTime: GATTBloodGlucoseMeasurementContext.MealTime {
		var mealTime: GATTBloodGlucoseMeasurementContext.MealTime = .unknown
		guard !context.isEmpty else {
			return mealTime
		}
		if context[0] == 2 {
			let carbID = context[3]
			mealTime = GATTBloodGlucoseMeasurementContext.MealTime(rawValue: carbID) ?? .unknown
		}

		return mealTime
	}
}

extension BloodGlucoseReading: CustomStringConvertible {
	public var description: String {
		"""
		{
		    sequence: \(sequence)
		    timeStamp: \(String(describing: utcTimestamp))
		    timezoneOffsetInSeconds: \(timezoneOffsetInSeconds)
		    concentration: \(concentration)
		    units: \(units.rawValue)
		    location: \(location)
		    type: \(type)
		    mealContext: \(mealContext)
		    mealTime: \(mealTime.rawValue)
		}
		"""
	}
}
