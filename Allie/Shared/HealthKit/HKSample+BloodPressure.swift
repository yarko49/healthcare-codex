//
//  HKCorrelation+OmronSDK.swift
//  Allie
//
//  Created by Waqar Malik on 2/2/22.
//

import CareModel
import Foundation
import HealthKit
import OmronKit

let BPMMetadataKeySequenceNumber = "BPMSequenceNumber"
let BPMMetadataKeyDeviceName = "BPMDeviceName"
let BPMMetadataKeyDeviceId = "BPMDeviceId"
let BPMMetadataKeyMeasurementRecord = "BPGMeasurementRecord"
let BPMMetadataKeyUserIndex = "BPMUserIndex"
let BPMMetadataKeyMeanArterialPressure = "BPMMeanArterialPressure"
let BPMMetadataKeyPulseRate = "BPMPulseRate"
let BPMMetadataKeyMeasurementStatus = "BPMBloodPressureMeasurementStatus"
let BPMMetadataKeyBatteryLevel = "BPMBatteryLevel"

extension HKSample {
	class func createBloodPressure(sessionData: SessionData, record: [OHQMeasurementRecordKey: Any]) throws -> HKSample {
		guard var systolic = record.systolic, var diastolic = record.diastolic else {
			throw AllieError.missing("Blood Pressure values")
		}

		if let unitString = record.bloodPressureUnit, unitString == "kPa" {
			systolic *= 7.500638
			diastolic *= 7.500638
		}

		let startDate = record.timeStamp ?? Date()
		let endDate = startDate
		let systolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic)!
		let systolicQuantity = HKQuantity(unit: HKUnit.millimeterOfMercury(), doubleValue: Double(systolic))
		let systolicSample = HKQuantitySample(type: systolicType, quantity: systolicQuantity, start: startDate, end: endDate)
		let diastolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic)!
		let diastolicQuantity = HKQuantity(unit: HKUnit.millimeterOfMercury(), doubleValue: Double(diastolic))
		let diastolicSample = HKQuantitySample(type: diastolicType, quantity: diastolicQuantity, start: startDate, end: endDate)
		let bloodPressureCorrelationType = HKCorrelationType.correlationType(forIdentifier: .bloodPressure)!
		let bloodPressureCorrelation = Set<HKSample>(arrayLiteral: systolicSample, diastolicSample)
		var metadata: [String: Any] = [:]
		metadata[HKMetadataKeyTimeZone] = TimeZone.current.identifier
		metadata[HKMetadataKeyWasUserEntered] = false
		metadata[CHMetadataKeyUpdatedDate] = Date()
		if let modelName = sessionData.modelName {
			metadata[BPMMetadataKeyDeviceName] = modelName
		}

		metadata[BPMMetadataKeyDeviceId] = sessionData.identifier.uuidString
		if let batteryLavel = sessionData.batteryLevel?.doubleValue {
			metadata[BPMMetadataKeyBatteryLevel] = batteryLavel
		}
		if let sequenceNumber = record.sequenceNumber {
			metadata[BPMMetadataKeySequenceNumber] = sequenceNumber
		}
		if let data = record.value {
			let base64Data = data.base64EncodedString()
			metadata[BPMMetadataKeyMeasurementRecord] = base64Data
		}
		if let userIndex = record.userIndex {
			metadata[BPMMetadataKeyUserIndex] = userIndex
		}

		if let meanArterialPressure = record.meanArterialPressure {
			metadata[BPMMetadataKeyMeanArterialPressure] = meanArterialPressure
		}

		if let pulseRate = record.pulseRate {
			metadata[BPMMetadataKeyPulseRate] = pulseRate
		}
		if let status = record.bloodPressureMeasurementStatus {
			metadata[BPMMetadataKeyMeasurementStatus] = status
		}

		let bloodPressureSample = HKCorrelation(type: bloodPressureCorrelationType, start: startDate, end: endDate, objects: bloodPressureCorrelation, metadata: metadata)
		return bloodPressureSample
	}
}

extension HKSample {
	class func createRestingHeartRate(sessionData: SessionData, record: [OHQMeasurementRecordKey: Any]) throws -> HKSample {
		guard let pulseRate = record.pulseRate else {
			throw AllieError.missing("Pulse rate")
		}

		let startDate = record.timeStamp ?? Date()
		let endDate = startDate
		let pulseRateType = HKQuantityType.quantityType(forIdentifier: .respiratoryRate)!
		let pulseRateQuantity = HKQuantity(unit: HKUnit.count().unitDivided(by: HKUnit.minute()), doubleValue: Double(pulseRate))

		var metadata: [String: Any] = [:]
		metadata[HKMetadataKeyTimeZone] = TimeZone.current.identifier
		metadata[HKMetadataKeyWasUserEntered] = false
		metadata[CHMetadataKeyUpdatedDate] = Date()
		if let modelName = sessionData.modelName {
			metadata[BPMMetadataKeyDeviceName] = modelName
		}

		metadata[BPMMetadataKeyDeviceId] = sessionData.identifier.uuidString
		if let batteryLavel = sessionData.batteryLevel?.doubleValue {
			metadata[BPMMetadataKeyBatteryLevel] = batteryLavel
		}
		if let sequenceNumber = record.sequenceNumber {
			metadata[BPMMetadataKeySequenceNumber] = sequenceNumber
		}
		if let data = record.value {
			let base64Data = data.base64EncodedString()
			metadata[BPMMetadataKeyMeasurementRecord] = base64Data
		}
		if let userIndex = record.userIndex {
			metadata[BPMMetadataKeyUserIndex] = userIndex
		}

		let pulseRateSample = HKQuantitySample(type: pulseRateType, quantity: pulseRateQuantity, start: startDate, end: endDate, metadata: metadata)
		return pulseRateSample
	}
}
