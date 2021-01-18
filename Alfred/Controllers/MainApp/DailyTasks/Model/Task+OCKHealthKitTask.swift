//
//  Task+OCKHealthKitTask.swift
//  Alfred
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
		self.init(id: task.id, title: task.title, carePlanUUID: nil, schedule: schedule, healthKitLinkage: task.healthKitLinkage!)
		self.instructions = task.instructions
		self.impactsAdherence = task.impactsAdherence
		self.groupIdentifier = task.groupIdentifier
		self.tags = task.tags
		self.effectiveDate = task.effectiveDate
		self.remoteID = task.remoteId
		self.source = task.source
		self.userInfo = task.userInfo
		self.asset = task.asset
		self.notes = task.notes?.values.map { (note) -> OCKNote in
			OCKNote(note: note)
		}
		self.timezone = task.timezone
		if let carePlanId = task.carePlanId {
			var metaData = userInfo ?? [:]
			metaData["carePlanId"] = carePlanId
			self.userInfo = metaData
		}
	}
}
