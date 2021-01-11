//
//  OCKTask+Conversion.swift
//  Alfred
//
//  Created by Waqar Malik on 12/8/20.
//

import CareKitStore
import Foundation

extension OCKTask {
	init(task: Task) {
		let scheduleElements = task.schedules?.values.map { (element) -> OCKScheduleElement in
			OCKScheduleElement(scheduleElement: element)
		} ?? []

		let schedule = OCKSchedule(composing: scheduleElements)
		self.init(id: task.id, title: task.title, carePlanUUID: nil, schedule: schedule)
		self.instructions = task.instructions
		self.impactsAdherence = task.impactsAdherence
		self.groupIdentifier = task.groupIdentifier
		self.tags = task.tags
		self.effectiveDate = task.effectiveDate ?? Date()
		self.remoteID = task.remoteId
		self.source = task.source
		self.userInfo = task.userInfo
		self.asset = task.asset
		self.notes = task.notes?.values.map { (note) -> OCKNote in
			OCKNote(note: note)
		}
		self.timezone = task.timezone
		if let uuidString = task.carePlanId, let uuid = UUID(uuidString: uuidString) {
			self.carePlanUUID = uuid
		}
	}
}

extension Task {
	init(ockTask: OCKTask) {
		self.carePlanId = ockTask.uuid?.uuidString
		self.id = ockTask.id
		self.title = ockTask.title
		self.instructions = ockTask.instructions
		self.impactsAdherence = ockTask.impactsAdherence
		let schduleElements = ockTask.schedule.elements
		var schedule: [String: ScheduleElement] = [:]
		var suffix: UInt8 = 65
		for ockElement in schduleElements {
			let element = ScheduleElement(ockScheduleElement: ockElement)
			let character = Character(UnicodeScalar(suffix))
			let key = "schedule" + String(character)
			schedule[key] = element
			suffix += 1
		}
		self.schedules = schedule
		self.carePlanId = ockTask.carePlanUUID?.uuidString
		self.groupIdentifier = ockTask.groupIdentifier
		self.tags = ockTask.tags
		self.effectiveDate = ockTask.effectiveDate
		self.createDate = ockTask.createdDate
		self.updatedDate = ockTask.updatedDate
		self.remoteId = ockTask.remoteID
		self.source = ockTask.source
		self.userInfo = ockTask.userInfo
		if let ockNotes = ockTask.notes {
			self.notes = [:]
			for ockNote in ockNotes {
				let note = Note(ockNote: ockNote)
				if let id = note.id {
					notes?[id] = note
				}
			}
		}
		self.timezone = ockTask.timezone
	}
}
