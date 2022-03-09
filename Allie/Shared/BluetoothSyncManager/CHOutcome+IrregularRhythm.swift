//
//  CHOutcome+IrregularRhythm.swift
//  Allie
//
//  Created by Waqar Malik on 3/9/22.
//

import BluetoothService
import CareKitStore
import CareModel
import Foundation
import HealthKit
import OmronKit

extension CHOutcome {
	init?(irregularRhythm sessionData: SessionData, record: [OHQMeasurementRecordKey: Any]) {
		guard let measurementStatusNumber = record[.bloodPressureMeasurementStatusKey] as? NSNumber else {
			return nil
		}

		let value = measurementStatusNumber.uint16Value
		let status = GATTBloodPressureMeasurement.MeasurementStatus(rawValue: value)
		guard !status.isPulseNormal else {
			return nil
		}

		var outcomeValue = CHOutcomeValue(true, units: "count")
		outcomeValue.kind = "irregular"

		self.init(taskUUID: UUID(), taskID: "measurements-blood-pressure", carePlanID: "defaultCarePlan", taskOccurrenceIndex: 0, values: [outcomeValue])
		self.effectiveDate = record.timeStamp ?? Date()
		self.startDate = effectiveDate
		self.createdDate = effectiveDate
		self.updatedDate = effectiveDate
		self.endDate = startDate
		self.remoteId = "measurements-blood-pressure"
		self.timezone = TimeZone.current
		self.groupIdentifier = CHGroupIdentifierType.irregularHeartRhythm.rawValue
		self.isBluetoothCollected = true

		var metadata: [String: String] = [:]
		metadata[HKMetadataKeyWasUserEntered] = "false"
		if let modelName = sessionData.modelName {
			metadata[BPMMetadataKeyDeviceName] = modelName
		}

		metadata[BPMMetadataKeyDeviceId] = sessionData.identifier.uuidString
		if let batteryLavel = sessionData.batteryLevel?.doubleValue {
			metadata[BPMMetadataKeyBatteryLevel] = String(batteryLavel)
		}
		if let sequenceNumber = record.sequenceNumber {
			metadata[BPMMetadataKeySequenceNumber] = String(sequenceNumber)
		}
		if let data = record.value {
			let base64Data = data.base64EncodedString()
			metadata[BPMMetadataKeyMeasurementRecord] = base64Data
		}
		if let userIndex = record.userIndex {
			metadata[BPMMetadataKeyUserIndex] = String(userIndex)
		}
		self.userInfo = metadata
	}
}
