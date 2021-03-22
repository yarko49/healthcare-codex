//
//  OCKTask+Conversion.swift
//  Allie
//
//  Created by Waqar Malik on 12/8/20.
//

import CareKitStore
import Foundation

protocol AnyTaskExtensible: AnyUserInfoExtensible {
	var priority: Int { get set }
	var carePlanId: String? { get set }
	var featuredContentDetailViewImageLabel: String? { get set }
	var featuredContentDetailViewHTML: String? { get set }
	var featuredContentDetailViewCSS: String? { get set }
	var featuredContentDetailViewText: String? { get set }
	var featuredContentDetailViewURL: URL? { get set }
	var featuredContentImageURL: URL? { get set }
	var category: String? { get set }
	var subtitle: String? { get set }
	var logText: String? { get set }
}

extension OCKTask: AnyTaskExtensible {}

extension OCKTask {
	init(task: Task) {
		let schedule = task.ockSchedule
		self.init(id: task.id, title: task.title, carePlanUUID: task.carePlanUUID, schedule: schedule)
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
		} else {
			self.notes = nil
		}
		self.timezone = task.timezone
		self.carePlanId = task.carePlanId
	}
}

extension AnyTaskExtensible {
	var priority: Int {
		get {
			getInt(forKey: "priority")
		}
		set {
			set(integer: newValue, forKey: "priority")
		}
	}

	var featuredContentDetailViewImageLabel: String? {
		get {
			userInfo?["detailViewImageLabel"]
		}
		set {
			setUserInfo(string: newValue, forKey: "detailViewImageLabel")
		}
	}

	var featuredContentDetailViewHTML: String? {
		get {
			userInfo?["detailViewHTML"]
		}
		set {
			setUserInfo(string: newValue, forKey: "detailViewHTML")
		}
	}

	var featuredContentDetailViewCSS: String? {
		get {
			userInfo?["detailViewCSS"]
		}
		set {
			setUserInfo(string: newValue, forKey: "detailViewCSS")
		}
	}

	var featuredContentDetailViewText: String? {
		get {
			userInfo?["detailViewText"]
		}
		set {
			setUserInfo(string: newValue, forKey: "detailViewText")
		}
	}

	var featuredContentDetailViewURL: URL? {
		get {
			guard let urlString = userInfo?["detailViewURL"] else {
				return nil
			}

			return URL(string: urlString)
		}
		set {
			setUserInfo(string: newValue?.absoluteString, forKey: "detailViewURL")
		}
	}

	var featuredContentImageURL: URL? {
		get {
			guard let urlString = userInfo?["image"] else {
				return nil
			}
			return URL(string: urlString)
		}
		set {
			setUserInfo(string: newValue?.absoluteString, forKey: "image")
		}
	}

	var category: String? {
		get {
			userInfo?["category"]
		}
		set {
			setUserInfo(string: newValue, forKey: "category")
		}
	}

	var subtitle: String? {
		get {
			userInfo?["subtitle"]
		}
		set {
			setUserInfo(string: newValue, forKey: "subtitle")
		}
	}

	var logText: String? {
		get {
			userInfo?["logText"]
		}
		set {
			setUserInfo(string: newValue, forKey: "logText")
		}
	}
}

extension AnyTaskExtensible where Self: OCKAnyTask {
	var carePlanId: String? {
		get {
			userInfo?["carePlanId"]
		}
		set {
			setUserInfo(string: newValue, forKey: "carePlanId")
		}
	}
}

extension Task {
	init(ockTask: OCKTask) {
		self.carePlanId = ockTask.carePlanId
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
