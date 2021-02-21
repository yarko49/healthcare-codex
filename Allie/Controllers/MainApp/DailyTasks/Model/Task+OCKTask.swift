//
//  OCKTask+Conversion.swift
//  Allie
//
//  Created by Waqar Malik on 12/8/20.
//

import CareKitStore
import Foundation

extension OCKTask {
	init(task: Task) {
		let schedule = task.ockSchedule
		self.init(id: task.id, title: task.title, carePlanUUID: nil, schedule: schedule)
		self.instructions = task.instructions
		self.impactsAdherence = task.impactsAdherence
		self.groupIdentifier = task.groupIdentifier
		self.tags = task.tags
		self.effectiveDate = task.effectiveDate
		self.remoteID = task.remoteId
		self.source = task.source
		self.userInfo = task.userInfo
		self.asset = task.asset
		// self.notes = task.notes?.values
		self.timezone = task.timezone
		self.carePlanId = task.carePlanId
	}
}

extension OCKTask {
	var carePlanId: String? {
		get {
			userInfo?["carePlanId"]
		}
		set {
			if let planId = newValue {
				var metaData = userInfo ?? [:]
				metaData["carePlanId"] = planId
				userInfo = metaData
			} else {
				userInfo?.removeValue(forKey: "carePlanId")
			}
		}
	}

	var featuredContent: [String: String]? {
		let keys: Set<String> = ["detailView", "detailViewImageLabel", "image", "detailViewCSS", "detailViewHTML", "detailViewImageLabel"]
		let content = userInfo?.reduce([:]) { (result, item) -> [String: String] in
			guard keys.contains(item.key) else {
				return result
			}
			var newResult = result
			newResult[item.key] = item.value
			return newResult
		}
		return content
	}

	var featuredContentImageURL: URL? {
		guard let urlString = featuredContent?["image"] else {
			return nil
		}
		return URL(string: urlString)
	}
}

extension Task {
	init(ockTask: OCKTask) {
		self.carePlanId = ockTask.uuid.uuidString
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
		self.carePlanId = ockTask.carePlanId
		self.groupIdentifier = ockTask.groupIdentifier
		self.tags = ockTask.tags
		self.effectiveDate = ockTask.effectiveDate
		self.createDate = ockTask.createdDate
		self.updatedDate = ockTask.updatedDate
		self.remoteId = ockTask.remoteID
		self.source = ockTask.source
		self.userInfo = ockTask.userInfo
		self.timezone = ockTask.timezone
	}
}

extension Task {
	var sortedScheduleElements: [ScheduleElement]? {
		schedules?.values.sorted(by: { (lhs, rhs) -> Bool in
			if lhs.hour < rhs.hour {
				return true
			} else if lhs.hour == rhs.hour {
				return lhs.minutes <= rhs.minutes // if the hours are same then minutes decide
			} else {
				return false // if hour is greator
			}
		})
	}

	var ockScheduleElements: [OCKScheduleElement] {
		let elements = sortedScheduleElements?.map { (element) -> OCKScheduleElement in
			element.ockSchduleElement
		} ?? []

		return elements
	}

	var ockSchedule: OCKSchedule {
		OCKSchedule(composing: ockScheduleElements)
	}

	var ockTask: OCKAnyTask {
		healthKitLinkage != nil ? OCKHealthKitTask(task: self) : OCKTask(task: self)
	}
}
