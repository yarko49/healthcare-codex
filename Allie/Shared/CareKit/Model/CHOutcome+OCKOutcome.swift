//
//  OCKOutcome+Outcome.swift
//  Allie
//
//  Created by Waqar Malik on 4/6/21.
//

import CareKitStore
import Foundation
import HealthKit

let CHOutcomeMetadataKeyCarePlanId = "carePlanId"
let CHOutcomeMetadataKeyTaskId = "taskId"
let CHOutcomeMetadataKeyDevice = "device"
let CHOutcomeMetadataKeyProvenance = "provenance"
let CHOutcomeMetadataKeySourceRevision = "sourceRevision"
let CHOutcomeMetadataKeyStartDate = "startDate"
let CHOutcomeMetadataKeyEndDate = "endDate"

let CHMetadataKeyUpdatedDate = "CHUpdatedDate"
let CHMetadataKeyHealthKitSampleUUID = "CHHealthKitSampleUUID"
let CHMetadataKeyCarehKitTaskUUID = "CHCarehKitTaskUUID"
let CHMetadataKeyHealthKitQuantityIdentifier = "CHHealthKitQuantityIdentifier"
let CHMetadataKeyCarePlanUUID = "CHCarePlanUUID"
let CHMetadataKeyBPSystolicValue = "systolicValue"
let CHMetadataKeyBPDiastolicValue = "diastolicValue"

extension OCKAnyOutcome {
	var groupIdentifierType: CHGroupIdentifierType? {
		guard let groupIdentifier = groupIdentifier else {
			return nil
		}
		return CHGroupIdentifierType(rawValue: groupIdentifier)
	}
}

extension OCKOutcome: AnyUserInfoExtensible, AnyItemDeletable {
	init(outcome: CHOutcome) {
		let ockOutcomeValues = outcome.values.map { outcomeValue -> OCKOutcomeValue in
			OCKOutcomeValue(outcomeValue: outcomeValue)
		}
		self.init(taskUUID: outcome.taskUUID, taskOccurrenceIndex: outcome.taskOccurrenceIndex, values: ockOutcomeValues)
		groupIdentifier = outcome.groupIdentifier
		uuid = outcome.uuid
		remoteID = outcome.remoteId
		notes = outcome.notes
		asset = outcome.asset
		source = outcome.source
		tags = outcome.tags
		timezone = outcome.timezone
		userInfo = outcome.userInfo
		if let date = createdDate {
			if date > outcome.createdDate {
				self.createdDate = outcome.createdDate
			}
		} else {
			self.createdDate = outcome.createdDate
		}
		effectiveDate = outcome.effectiveDate
		deletedDate = outcome.deletedDate
		updatedDate = outcome.updatedDate
		setUserInfo(string: outcome.carePlanId, forKey: CHOutcomeMetadataKeyCarePlanId)
		setUserInfo(string: outcome.taskId, forKey: CHOutcomeMetadataKeyTaskId)
		if let device = outcome.device, let data = try? JSONEncoder().encode(device) {
			let deviceString = String(data: data, encoding: .utf8)
			setUserInfo(string: deviceString, forKey: CHOutcomeMetadataKeyDevice)
		}

		if let provenance = outcome.provenance, let data = try? JSONEncoder().encode(provenance) {
			let provenanceString = String(data: data, encoding: .utf8)
			setUserInfo(string: provenanceString, forKey: CHOutcomeMetadataKeyProvenance)
		}

		if let sourceRevision = outcome.sourceRevision, let data = try? JSONEncoder().encode(sourceRevision) {
			let sourceRevisionString = String(data: data, encoding: .utf8)
			setUserInfo(string: sourceRevisionString, forKey: CHOutcomeMetadataKeySourceRevision)
		}
		if let date = outcome.startDate {
			let dateString = DateFormatter.wholeDateRequest.string(from: date)
			setUserInfo(string: dateString, forKey: CHOutcomeMetadataKeyStartDate)
		}

		if let date = outcome.endDate {
			let dateString = DateFormatter.wholeDateRequest.string(from: date)
			setUserInfo(string: dateString, forKey: CHOutcomeMetadataKeyEndDate)
		}

		setUserInfo(string: String(!outcome.isBluetoothCollected), forKey: HKMetadataKeyWasUserEntered)
		self.healthKitSampleUUID = outcome.healthKit?.sampleUUID
		if let identifier = outcome.healthKit?.quantityIdentifier {
			self.healthKitQuantityIdentifier = HKQuantityTypeIdentifier(rawValue: identifier)
		}
		self.carePlanUUID = outcome.carePlanUUID
	}

	var healthKitSampleUUID: UUID? {
		get {
			guard let value = userInfo(forKey: CHMetadataKeyHealthKitSampleUUID, excludeEmptyString: true) else {
				return nil
			}
			return UUID(uuidString: value)
		}
		set {
			setUserInfo(string: newValue?.uuidString, forKey: CHMetadataKeyHealthKitSampleUUID)
		}
	}

	var healthKitQuantityIdentifier: HKQuantityTypeIdentifier? {
		get {
			guard let value = userInfo(forKey: CHMetadataKeyHealthKitQuantityIdentifier, excludeEmptyString: true) else {
				return nil
			}
			return HKQuantityTypeIdentifier(rawValue: value)
		}
		set {
			setUserInfo(string: newValue?.rawValue, forKey: CHMetadataKeyHealthKitQuantityIdentifier)
		}
	}

	var carePlanUUID: UUID? {
		get {
			guard let value = userInfo(forKey: CHMetadataKeyHealthKitSampleUUID, excludeEmptyString: true) else {
				return nil
			}
			return UUID(uuidString: value)
		}
		set {
			setUserInfo(string: newValue?.uuidString, forKey: CHMetadataKeyHealthKitSampleUUID)
		}
	}
}

extension CHOutcome {
	init(outcome: OCKOutcome, carePlanID: String, task: OCKAnyTask) {
		let values = outcome.values.map { outcome in
			CHOutcomeValue(ockOutcomeValue: outcome)
		}
		self.init(taskUUID: outcome.taskUUID, taskID: task.id, carePlanID: carePlanID, taskOccurrenceIndex: outcome.taskOccurrenceIndex, values: values)
		groupIdentifier = task.groupIdentifier
		remoteId = outcome.remoteID
		uuid = outcome.uuid
		notes = outcome.notes
		asset = outcome.asset
		source = outcome.source
		tags = outcome.tags
		timezone = outcome.timezone
		userInfo = outcome.userInfo
		createdDate = outcome.createdDate ?? Date()
		deletedDate = outcome.deletedDate
		effectiveDate = outcome.effectiveDate
		updatedDate = outcome.updatedDate

		if let deviceString = outcome.userInfo?[CHOutcomeMetadataKeyDevice], let data = deviceString.data(using: .utf8), let device = try? JSONDecoder().decode(CHDevice.self, from: data) {
			self.device = device
		}

		if let provenanceString = outcome.userInfo?[CHOutcomeMetadataKeyProvenance], let data = provenanceString.data(using: .utf8), let provenance = try? JSONDecoder().decode(CHProvenance.self, from: data) {
			self.provenance = provenance
		}

		if let sourceRevisionString = outcome.userInfo?[CHOutcomeMetadataKeySourceRevision], let data = sourceRevisionString.data(using: .utf8), let sourceRevision = try? JSONDecoder().decode(CHSourceRevision.self, from: data) {
			self.sourceRevision = sourceRevision
		}

		if let dateString = outcome.userInfo?[CHOutcomeMetadataKeyStartDate] {
			self.startDate = DateFormatter.wholeDateRequest.date(from: dateString)
		}

		if let dateString = outcome.userInfo?[CHOutcomeMetadataKeyEndDate] {
			self.endDate = DateFormatter.wholeDateRequest.date(from: dateString)
		}
		if let userEnteredString = outcome.userInfo?[HKMetadataKeyWasUserEntered] {
			self.isBluetoothCollected = !(Bool(userEnteredString) ?? false)
		}

		setHealthKit(sampleUUID: outcome.healthKitSampleUUID, quantityIdentifier: outcome.healthKitQuantityIdentifier)
	}
}

extension CHOutcome {
	mutating func setHealthKit(sampleUUID: UUID?, quantityIdentifier: HKQuantityTypeIdentifier?) {
		guard let uuid = sampleUUID, let identifier = quantityIdentifier else {
			return
		}
		healthKit = HealthKit(quantityIdentifier: identifier.rawValue, sampleUUID: uuid)
	}

	mutating func setHealthKit(sampleUUID: UUID?, quantityIdentifier: String?) {
		guard let identifier = quantityIdentifier else {
			return
		}
		setHealthKit(sampleUUID: sampleUUID, quantityIdentifier: HKQuantityTypeIdentifier(rawValue: identifier))
	}
}

extension OCKOutcome {
	func merged(newOutcome: OCKOutcome) -> Self {
		var existing = self
		existing.taskUUID = newOutcome.taskUUID
		existing.taskOccurrenceIndex = newOutcome.taskOccurrenceIndex
		existing.values = newOutcome.values
		existing.effectiveDate = newOutcome.effectiveDate
		if newOutcome.deletedDate != nil {
			existing.deletedDate = newOutcome.deletedDate
		}

		if newOutcome.updatedDate != nil {
			existing.updatedDate = newOutcome.updatedDate
		}

		if newOutcome.schemaVersion != nil {
			existing.schemaVersion = newOutcome.schemaVersion
		}

		if remoteID != nil {
			existing.remoteID = newOutcome.remoteID
		}

		if newOutcome.groupIdentifier != nil {
			existing.groupIdentifier = newOutcome.groupIdentifier
		}

		if newOutcome.tags != nil {
			existing.tags = newOutcome.tags
		}

		if newOutcome.source != nil {
			existing.source = newOutcome.source
		}

		if let userInfo = newOutcome.userInfo {
			existing.userInfo?.merge(userInfo, uniquingKeysWith: { _, newValue in
				newValue
			})
		}

		if newOutcome.asset != nil {
			existing.asset = newOutcome.asset
		}

		if newOutcome.notes != nil {
			existing.notes = newOutcome.notes
		}

		existing.timezone = newOutcome.timezone
		return existing
	}
}
