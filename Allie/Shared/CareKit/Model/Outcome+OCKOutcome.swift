//
//  OCKOutcome+Outcome.swift
//  Allie
//
//  Created by Waqar Malik on 4/6/21.
//

import CareKitStore
import Foundation

extension OCKOutcome: AnyUserInfoExtensible {
	init(outcome: Outcome) {
		let ockOutcomeValues = outcome.values.map { outcomeValue -> OCKOutcomeValue in
			OCKOutcomeValue(outcomeValue: outcomeValue)
		}
		self.init(taskUUID: outcome.taskUUID, taskOccurrenceIndex: outcome.taskOccurrenceIndex, values: ockOutcomeValues)
		groupIdentifier = outcome.groupIdentifier
		uuid = outcome.uuid
		remoteID = outcome.remoteID
		notes = outcome.notes
		asset = outcome.asset
		source = outcome.source
		tags = outcome.tags
		timezone = outcome.timezone
		userInfo = outcome.userInfo
		createdDate = outcome.createdDate
		deletedDate = outcome.deletedDate
		effectiveDate = outcome.effectiveDate
		updatedDate = outcome.updatedDate
		setUserInfo(string: outcome.carePlanID, forKey: "carePlanId")
		setUserInfo(string: outcome.taskID, forKey: "taskId")
		if let device = outcome.device, let data = try? JSONEncoder().encode(device) {
			let deviceString = String(data: data, encoding: .utf8)
			setUserInfo(string: deviceString, forKey: "device")
		}

		if let sourceRevision = outcome.sourceRevision, let data = try? JSONEncoder().encode(sourceRevision) {
			let sourceRevisionString = String(data: data, encoding: .utf8)
			setUserInfo(string: sourceRevisionString, forKey: "sourceRevision")
		}
		if let date = outcome.startDate {
			let dateString = DateFormatter.rfc3339.string(from: date)
			setUserInfo(string: dateString, forKey: "startDate")
		}

		if let date = outcome.endDate {
			let dateString = DateFormatter.rfc3339.string(from: date)
			setUserInfo(string: dateString, forKey: "endDate")
		}
	}
}

extension Outcome {
	init(outcome: OCKOutcome, carePlanID: String, taskID: String) {
		let values = outcome.values.map { outcome in
			OutcomeValue(ockOutcomeValue: outcome)
		}
		self.init(taskUUID: outcome.taskUUID, taskID: taskID, carePlanID: carePlanID, taskOccurrenceIndex: outcome.taskOccurrenceIndex, values: values)
		groupIdentifier = outcome.groupIdentifier
		remoteID = outcome.remoteID
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
		if let deviceString = outcome.userInfo?["device"], let data = deviceString.data(using: .utf8), let device = try? JSONDecoder().decode(CHDevice.self, from: data) {
			self.device = device
		}
		if let sourceRevisionString = outcome.userInfo?["sourceRevision"], let data = sourceRevisionString.data(using: .utf8), let sourceRevision = try? JSONDecoder().decode(CHSourceRevision.self, from: data) {
			self.sourceRevision = sourceRevision
		}

		if let dateString = outcome.userInfo?["startDate"] {
			self.startDate = DateFormatter.rfc3339.date(from: dateString)
		}

		if let dateString = outcome.userInfo?["endDate"] {
			self.endDate = DateFormatter.rfc3339.date(from: dateString)
		}
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
		if newOutcome.createdDate != nil {
			existing.createdDate = newOutcome.createdDate
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

		if newOutcome.userInfo != nil {
			existing.userInfo = newOutcome.userInfo
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
