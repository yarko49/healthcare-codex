//
//  HKSample+RestingHeartRate.swift
//  Allie
//
//  Created by Waqar Malik on 3/9/22.
//

import CareModel
import Foundation
import HealthKit
import OmronKit

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
