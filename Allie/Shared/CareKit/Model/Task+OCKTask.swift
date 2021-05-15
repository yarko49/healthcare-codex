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
	var featuredContentDetailViewAsset: String? { get set }
	var category: String? { get set }
	var subtitle: String? { get set }
	var logText: String? { get set }
}

extension OCKAnyTask {}

extension OCKTask: AnyTaskExtensible {}

extension OCKTask {
	init(task: Task) {
		let schedule = task.schedule
		self.init(id: task.id, title: task.title, carePlanUUID: task.carePlanUUID, schedule: schedule)
		self.instructions = task.instructions
		self.impactsAdherence = task.impactsAdherence
		self.groupIdentifier = task.groupIdentifier
		self.tags = task.tags
		self.effectiveDate = task.effectiveDate
		if let date = task.createdDate {
			self.createdDate = date
		}
//		if let date = task.updatedDate {
//			self.updatedDate = date
//		}
//		if let date = task.deletedDate {
//			self.deletedDate = date
//		}
		self.remoteID = task.remoteId
		self.source = task.source
		self.userInfo = task.userInfo
		self.asset = task.asset
		self.notes = task.notes
		self.timezone = task.timezone
		self.carePlanId = task.carePlanId
	}
}

extension OCKTask {
	func merged(new: OCKTask) -> Self {
		var existing = self
		existing.title = new.title
		existing.instructions = new.instructions
		existing.impactsAdherence = new.impactsAdherence
		existing.schedule = new.schedule
		existing.groupIdentifier = new.groupIdentifier
		existing.tags = new.tags
		existing.effectiveDate = new.effectiveDate
//		if let date = new.createdDate {
//			existing.createdDate = date
//		}
//		if let date = new.updatedDate {
//			existing.updatedDate = date
//		}
//		if let date = new.deletedDate {
//			existing.deletedDate = date
//		}
		existing.remoteID = new.remoteID
		existing.source = new.source
		existing.userInfo = new.userInfo
		existing.asset = new.asset
		existing.notes = new.notes
		existing.timezone = new.timezone
		if let carePlanId = new.carePlanId {
			existing.carePlanId = carePlanId
		}
		return existing
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
			userInfo(forKey: "detailViewImageLabel")
		}
		set {
			setUserInfo(string: newValue, forKey: "detailViewImageLabel")
		}
	}

	var featuredContentDetailViewHTML: String? {
		get {
			userInfo(forKey: "detailViewHTML")
		}
		set {
			setUserInfo(string: newValue, forKey: "detailViewHTML")
		}
	}

	var featuredContentDetailViewCSS: String? {
		get {
			userInfo(forKey: "detailViewCSS")
		}
		set {
			setUserInfo(string: newValue, forKey: "detailViewCSS")
		}
	}

	var featuredContentDetailViewText: String? {
		get {
			userInfo(forKey: "detailViewText")
		}
		set {
			setUserInfo(string: newValue, forKey: "detailViewText")
		}
	}

	var featuredContentDetailViewURL: URL? {
		get {
			guard let urlString = userInfo(forKey: "detailViewURL") else {
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
			guard let urlString = userInfo(forKey: "image") else {
				return nil
			}
			return URL(string: urlString)
		}
		set {
			setUserInfo(string: newValue?.absoluteString, forKey: "image")
		}
	}

	var featuredContentDetailViewAsset: String? {
		get {
			userInfo(forKey: "detailViewAsset")
		}
		set {
			setUserInfo(string: newValue, forKey: "detailViewAsset")
		}
	}

	var category: String? {
		get {
			userInfo(forKey: "category")
		}
		set {
			setUserInfo(string: newValue, forKey: "category")
		}
	}

	var subtitle: String? {
		get {
			userInfo(forKey: "subtitle")
		}
		set {
			setUserInfo(string: newValue, forKey: "subtitle")
		}
	}

	var logText: String? {
		get {
			userInfo(forKey: "logText")
		}
		set {
			setUserInfo(string: newValue, forKey: "logText")
		}
	}
}

extension AnyTaskExtensible where Self: OCKAnyTask {
	var carePlanId: String? {
		get {
			userInfo(forKey: "carePlanId")
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
		var schedule: [ScheduleElement] = []
		for ockElement in schduleElements {
			let element = ScheduleElement(ockScheduleElement: ockElement)
			schedule.append(element)
		}
		self.scheduleElements = schedule
		self.carePlanId = ockTask.carePlanId
		self.groupIdentifier = ockTask.groupIdentifier
		self.tags = ockTask.tags
		self.effectiveDate = ockTask.effectiveDate
		self.createdDate = ockTask.createdDate
		self.updatedDate = ockTask.updatedDate
		self.deletedDate = ockTask.deletedDate
		self.remoteId = ockTask.remoteID
		self.source = ockTask.source
		self.userInfo = ockTask.userInfo
		self.timezone = ockTask.timezone
		self.schedule = ockTask.schedule
	}
}

extension Task {
	var ockTask: OCKAnyTask {
		healthKitLinkage != nil ? OCKHealthKitTask(task: self) : OCKTask(task: self)
	}
}
