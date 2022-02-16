//
//  BloodGlucoseRecord.swift
//  Allie
//
//  Created by Waqar Malik on 7/27/21.
//

import CoreBluetooth
import Foundation

public struct BloodGlucoseRecord: Identifiable, Hashable {
	public let sequence: Int
	public let utcTimestamp: Date
	public let timezoneOffsetInSeconds: Int
	public let glucoseConcentration: Double
	public let concentrationUnit: GATTBloodGlucoseMeasurement.ConcentrationUnit
	public let sampleType: String
	public let sampleLocation: String
	public var sensorFlags: GATTBloodGlucoseMeasurement.SensorFlags
	public let mealContext: String
	public let mealTime: GATTBloodGlucoseMeasurementContext.MealTime
	public let peripheral: CBPeripheral?

	public let measurementData: Data // Data Encoding ascii
	public let contextData: Data? // Data Encoding ascii

	public var id: Int {
		sequence
	}

	// For now just use the device timezone
	public var timeZone: TimeZone {
		.current // TimeZone(secondsFromGMT: timezoneOffsetInSeconds) ?? .current
	}

	public init(sequence: Int, utcTimestamp: Date, timezoneOffsetInSeconds: Int, glucoseConcentration: Double, concentrationUnit: GATTBloodGlucoseMeasurement.ConcentrationUnit, sampleType: String, sampleLocation: String, sensorFlags: GATTBloodGlucoseMeasurement.SensorFlags, mealContext: String, mealTime: GATTBloodGlucoseMeasurementContext.MealTime, peripheral: CBPeripheral?, measurementData: Data, contextData: Data?) {
		self.sequence = sequence
		self.utcTimestamp = utcTimestamp
		self.timezoneOffsetInSeconds = timezoneOffsetInSeconds
		self.glucoseConcentration = glucoseConcentration
		self.concentrationUnit = concentrationUnit
		self.sampleType = sampleType
		self.sampleLocation = sampleLocation
		self.sensorFlags = sensorFlags
		self.mealContext = mealContext
		self.mealTime = mealTime
		self.peripheral = peripheral
		self.measurementData = measurementData
		self.contextData = contextData
	}
}

public extension BloodGlucoseRecord {
	init(reading: BloodGlucoseReading) {
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
		self.sensorFlags = []
	}
}

public extension BloodGlucoseRecord {
	init(measurement: [Int], context: [Int], peripheral: CBPeripheral?, measurementData: Data, contextData: Data?) {
		self.init(reading: BloodGlucoseReading(measurement: measurement, context: context, peripheral: peripheral, measurementData: measurementData, contextData: contextData))
	}
}
