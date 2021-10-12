//
//  CHOutcome+OCKHealthKitOutcome.swift
//  Allie
//
//  Created by Waqar Malik on 8/5/21.
//

import CareKitStore
import Foundation
import HealthKit

extension CHOutcome {
	init(hkOutcome: OCKHealthKitOutcome, carePlanID: String, taskID: String) {
		let values = hkOutcome.values.map { outcome in
			CHOutcomeValue(ockOutcomeValue: outcome)
		}
		self.init(taskUUID: hkOutcome.taskUUID, taskID: taskID, carePlanID: carePlanID, taskOccurrenceIndex: hkOutcome.taskOccurrenceIndex, values: values)
		groupIdentifier = hkOutcome.groupIdentifier
		remoteID = hkOutcome.remoteID
		notes = hkOutcome.notes
	}
}
