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

extension OCKHealthKitTask: AnyTaskExtensible {}
