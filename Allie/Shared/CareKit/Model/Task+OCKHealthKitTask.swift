//
//  Task+OCKHealthKitTask.swift
//  Allie
//
//  Created by Waqar Malik on 1/14/21.
//

import CareKit
import CareKitStore
import Foundation
import HealthKit

extension OCKHealthKitTask {
	init(task: Task) {
		let schedule = task.ockSchedule
		self.init(id: task.id, title: task.title, carePlanUUID: task.carePlanUUID, schedule: schedule, healthKitLinkage: task.healthKitLinkage!)
		self.instructions = task.instructions
		self.impactsAdherence = task.impactsAdherence
		self.groupIdentifier = task.groupIdentifier
		self.tags = task.tags
		self.effectiveDate = task.effectiveDate
		self.remoteID = task.remoteId
		self.source = task.source
		self.userInfo = task.userInfo
		self.asset = task.asset
		if let notes = task.notes?.values {
			self.notes = Array(notes)
		}
		self.timezone = task.timezone
		self.carePlanId = task.carePlanId
	}
}

extension OCKHealthKitTask {
	func merged(newTask: OCKHealthKitTask) -> Self {
		var merged = self
		merged.healthKitLinkage = newTask.healthKitLinkage
		merged.title = newTask.title
		merged.instructions = newTask.instructions
		merged.impactsAdherence = newTask.impactsAdherence
		merged.schedule = newTask.schedule
		merged.groupIdentifier = newTask.groupIdentifier
		merged.tags = newTask.tags
		merged.remoteID = newTask.remoteID
		merged.source = newTask.source
		merged.userInfo = newTask.userInfo
		merged.asset = newTask.asset
		merged.notes = newTask.notes
		merged.timezone = newTask.timezone
		return merged
	}
}

extension OCKHealthKitTask: AnyTaskExtensible {}
