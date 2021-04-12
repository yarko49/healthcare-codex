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
		let ockOutcomeValues = outcome.values.map { (outcomeValue) -> OCKOutcomeValue in
			OCKOutcomeValue(outcomeValue: outcomeValue)
		}
		self.init(taskUUID: outcome.id, taskOccurrenceIndex: outcome.taskOccurrenceIndex, values: ockOutcomeValues)
		groupIdentifier = outcome.groupIdentifier
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
	}
}

extension Outcome {
	init(outcome: OCKOutcome, carePlanID: String, taskID: String) {
		self.init(id: outcome.taskUUID, taskID: taskID, carePlanID: carePlanID, taskOccurrenceIndex: outcome.taskOccurrenceIndex, values: outcome.values)
		groupIdentifier = outcome.groupIdentifier
		remoteID = outcome.remoteID
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
	}
}
