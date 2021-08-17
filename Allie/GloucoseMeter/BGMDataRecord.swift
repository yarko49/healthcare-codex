//
//  GlucoseDataRecord.swift
//  Allie
//
//  Created by Waqar Malik on 7/27/21.
//

import CoreBluetooth
import Foundation

enum GlucoseConcentrationUnit: String, Hashable {
	case mole = "mol/L"
	case kg = "kg/L"
}

struct BGMDataRecord: Identifiable, Hashable {
	let sequence: Int
	let timestamp: Date
	let timezoneOffsetInSeconds: Int
	let glucoseConcentration: Double
	let concentrationUnit: GlucoseConcentrationUnit
	let bloodType: String
	let sampleLocation: String
	// var sensorFlags: Flags
	let mealContext: String
	let mealTime: BGMMealTime
	let peripheral: CBPeripheral?

	var id: UUID? {
		peripheral?.identifier
	}

	var timeZone: TimeZone {
		TimeZone(secondsFromGMT: timezoneOffsetInSeconds) ?? .current
	}
}

extension BGMDataRecord {
	init(reading: BGMDataReading) {
		self.peripheral = reading.peripheral
		self.sequence = reading.sequence
		self.timestamp = reading.timestamp ?? Date()
		self.timezoneOffsetInSeconds = reading.timezoneOffsetInSeconds
		self.concentrationUnit = reading.units
		self.bloodType = reading.type
		self.sampleLocation = reading.location
		self.mealContext = reading.mealContext
		var glucoseValue = reading.concentration
		if concentrationUnit == .kg { // this is the Bluetooth GATT standard unit for blood glucose
			glucoseValue = glucoseValue * 100000 // convert to mg/dL for HK
		}
		self.glucoseConcentration = glucoseValue
		self.mealTime = reading.mealTime
	}
}

extension BGMDataRecord {
	init(measurement: [Int], context: [Int], peripheral: CBPeripheral?) {
		self.init(reading: BGMDataReading(measurement: measurement, context: context, peripheral: peripheral))
	}
}
