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
	let utcTimestamp: Date
	let timezoneOffsetInSeconds: Int
	let glucoseConcentration: Double
	let concentrationUnit: GlucoseConcentrationUnit
	let sampleType: String
	let sampleLocation: String
	// var sensorFlags: Flags
	let mealContext: String
	let mealTime: CHBloodGlucoseMealTime
	let peripheral: CBPeripheral?

	let measurementData: Data
	let contextData: Data?

	var id: UUID? {
		peripheral?.identifier
	}

	// For now just use the device timezone
	var timeZone: TimeZone {
		.current // TimeZone(secondsFromGMT: timezoneOffsetInSeconds) ?? .current
	}
}

extension BGMDataRecord {
	init(reading: BGMDataReading) {
		self.peripheral = reading.peripheral
		self.sequence = reading.sequence
		self.utcTimestamp = reading.utcTimestamp ?? Date()
		self.timezoneOffsetInSeconds = reading.timezoneOffsetInSeconds
		self.concentrationUnit = reading.units
		self.sampleType = reading.type
		self.sampleLocation = reading.location
		self.mealContext = reading.mealContext
		var glucoseValue = reading.concentration
		if concentrationUnit == .kg { // this is the Bluetooth GATT standard unit for blood glucose
			glucoseValue = glucoseValue * 100000 // convert to mg/dL for HK
		}
		self.glucoseConcentration = glucoseValue
		self.mealTime = reading.mealTime
		self.measurementData = reading.measurementData
		self.contextData = reading.contextData
	}
}

extension BGMDataRecord {
	init(measurement: [Int], context: [Int], peripheral: CBPeripheral?, measurementData: Data, contextData: Data?) {
		self.init(reading: BGMDataReading(measurement: measurement, context: context, peripheral: peripheral, measurementData: measurementData, contextData: contextData))
	}
}
