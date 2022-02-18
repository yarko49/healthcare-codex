//
//  HKSample+BodyMass.swift
//  Allie
//
//  Created by Waqar Malik on 2/16/22.
//

import Foundation
import HealthKit
import OmronKit

let BMMetadataKeyDeviceName = "DeviceName"
let BMMetadataKeyDeviceId = "DeviceId"
let BMMetadataKeyMeasurementRecord = "MeasurementRecord"
let BMMetadataKeyUserIndex = "UserIndex"
let BMMetadataKeyBatteryLevel = "BatteryLevel"
let BMMetadataKeySequenceNumber = "SequenceNumber"
let BMMetadataKeyBMI = "BMI"
let BMMetadataKeyBodyFatPercentage = "BodyFatPercentage"
let BMMetadataKeyBasalMetabolism = "BasalMetabolism"
let BMMetadataKeyMusclePercentage = "MusclePercentage"
let BMMetadataKeyMuscleMass = "MuscleMass"

extension HKSample {
	class func createBodyMass(sessionData: SessionData, record: [OHQMeasurementRecordKey: Any]) throws -> HKSample {
		guard var weight = record.weight else {
			throw AllieError.missing("weight")
		}

		if let unitString = record.weightUnit, unitString == "kg" {
			weight *= 2.204623
		}

		let startDate = record.timeStamp ?? Date()
		let endDate = startDate
		let bodyMassType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
		let bodyMassQuantity = HKQuantity(unit: HKUnit.pound(), doubleValue: weight)
		var metadata: [String: Any] = [:]
		metadata[HKMetadataKeyTimeZone] = TimeZone.current.identifier
		metadata[HKMetadataKeyWasUserEntered] = false
		metadata[CHMetadataKeyUpdatedDate] = Date()
		if let modelName = sessionData.modelName {
			metadata[BMMetadataKeyDeviceName] = modelName
		}

		metadata[BMMetadataKeyDeviceId] = sessionData.identifier.uuidString
		if let batteryLavel = sessionData.batteryLevel?.doubleValue {
			metadata[BMMetadataKeyBatteryLevel] = batteryLavel
		}
		if let sequenceNumber = record.sequenceNumber {
			metadata[BMMetadataKeySequenceNumber] = sequenceNumber
		}
		if let data = record.value {
			let base64Data = data.base64EncodedString()
			metadata[BMMetadataKeyMeasurementRecord] = base64Data
		}
		if let userIndex = record.userIndex {
			metadata[BMMetadataKeyUserIndex] = userIndex
		}

		if let bmi = record.bmi {
			metadata[BMMetadataKeyBMI] = bmi
		}
		if let bfp = record.bodyFatPercentage {
			metadata[BMMetadataKeyBodyFatPercentage] = bfp
		}

		if let bm = record.basalMetabolism {
			metadata[BMMetadataKeyBasalMetabolism] = bm
		}

		if let musclePercentage = record.musclePercentage {
			metadata[BMMetadataKeyMusclePercentage] = musclePercentage
		}

		if var muscleMass = record.muscleMass {
			if let muscleMassUnit = record.muscleMassUnit, muscleMassUnit == "kg" {
				muscleMass *= 2.204623
			}
			metadata[BMMetadataKeyMuscleMass] = muscleMass
		}

		// TODO: make the device from CHPerpherial
		let sample = HKDiscreteQuantitySample(type: bodyMassType, quantity: bodyMassQuantity, start: startDate, end: endDate, device: HKDevice.local(), metadata: metadata)
		return sample
	}
}
