//
//  AllieTask+OCKHealthKitTask.swift
//  Allie
//
//  Created by Waqar Malik on 1/14/21.
//

import CareKit
import CareKitStore
import Foundation
import HealthKit

extension OCKHealthKitTask {
	init(task: CHTask) {
		let schedule = task.schedule
		self.init(id: task.id, title: task.title, carePlanUUID: task.carePlanUUID, schedule: schedule, healthKitLinkage: task.healthKitLinkage!)
		self.instructions = task.instructions
		self.impactsAdherence = task.impactsAdherence
		self.groupIdentifier = task.groupIdentifier
		self.tags = task.tags
		self.effectiveDate = task.effectiveDate
		self.remoteID = task.remoteID
		self.source = task.source
		self.userInfo = task.userInfo
		self.asset = task.asset
		self.notes = task.notes
		self.timezone = task.timezone
		self.carePlanId = task.carePlanId
	}

	func updated(new: CHTask) -> OCKHealthKitTask {
		var updated = self
		updated.instructions = new.instructions
		updated.impactsAdherence = new.impactsAdherence
		updated.tags = new.tags
		updated.source = new.source
		updated.userInfo = new.userInfo
		updated.asset = new.asset
		updated.notes = new.notes

		return updated
	}

	func merged(new: OCKHealthKitTask) -> Self {
		var merged = self
		merged.healthKitLinkage = new.healthKitLinkage
		merged.title = new.title
		merged.instructions = new.instructions
		merged.impactsAdherence = new.impactsAdherence
		merged.schedule = new.schedule
		merged.groupIdentifier = new.groupIdentifier
		merged.tags = new.tags
		merged.remoteID = new.remoteID
		merged.source = new.source
		merged.userInfo = new.userInfo
		merged.asset = new.asset
		merged.notes = new.notes
		merged.timezone = new.timezone
		return merged
	}

	mutating func merge(new: OCKHealthKitTask) {
		title = new.title
		instructions = new.instructions
		impactsAdherence = new.impactsAdherence
		tags = new.tags
		source = new.source
		userInfo = new.userInfo
		asset = new.asset
		notes = new.notes
	}
}

extension OCKHealthKitTask: AnyTaskExtensible {
	var isActive: Bool {
		let date = Date()
		if effectiveDate > date {
			return false
		}
		if let deletedDate = deletedDate, deletedDate < date {
			return false
		}
		return true
	}
}
