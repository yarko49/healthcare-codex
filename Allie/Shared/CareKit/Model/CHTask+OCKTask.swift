//
//  AllieTask+OCKTask.swift
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
	var links: [CHLink]? { get set }
}

extension OCKAnyTask {}

extension OCKTask: AnyTaskExtensible, AnyItemDeletable {}

extension OCKTask {
	init(task: CHTask) {
		let schedule = task.schedule
		self.init(id: task.id, title: task.title, carePlanUUID: task.carePlanUUID, schedule: schedule)
		self.instructions = task.instructions
		self.impactsAdherence = task.impactsAdherence
		self.groupIdentifier = task.groupIdentifier
		self.tags = task.tags
		if let date = createdDate {
			if date > task.createdDate {
				self.createdDate = task.createdDate
			}
		} else {
			self.createdDate = task.createdDate
		}
		self.effectiveDate = task.effectiveDate
		self.updatedDate = task.updatedDate
		self.remoteID = task.remoteId
		self.source = task.source
		self.userInfo = task.userInfo
		self.asset = task.asset
		self.notes = task.notes
		self.timezone = task.timezone
		self.carePlanId = task.carePlanId
		self.links = task.links
	}

	func updated(new: CHTask) -> OCKTask {
		var updated = self
		updated.instructions = new.instructions
		updated.impactsAdherence = new.impactsAdherence
		updated.tags = new.tags
		updated.source = new.source
		updated.userInfo = new.userInfo
		updated.asset = new.asset
		updated.notes = new.notes
		updated.links = new.links
		return updated
	}

	func merged(new: OCKTask) -> Self {
		var existing = self
		existing.deletedDate = nil
		existing.title = new.title
		existing.instructions = new.instructions
		existing.impactsAdherence = new.impactsAdherence
		existing.schedule = new.schedule
		existing.groupIdentifier = new.groupIdentifier
		existing.tags = new.tags
		existing.remoteID = new.remoteID
		existing.source = new.source
		existing.userInfo = new.userInfo
		existing.asset = new.asset
		existing.notes = new.notes
		existing.timezone = new.timezone
		if let carePlanId = new.carePlanId {
			existing.carePlanId = carePlanId
		}
		existing.links = new.links
		return existing
	}

	mutating func merge(new: OCKTask) {
		title = new.title
		instructions = new.instructions
		impactsAdherence = new.impactsAdherence
		schedule = new.schedule
		groupIdentifier = new.groupIdentifier
		tags = new.tags
		remoteID = new.remoteID
		source = new.source
		userInfo = new.userInfo
		asset = new.asset
		notes = new.notes
		timezone = new.timezone
		if let carePlanId = new.carePlanId {
			self.carePlanId = carePlanId
		}
		links = new.links
		deletedDate = nil
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

	var linksExist: Bool {
		userInfo(forKey: "links", excludeEmptyString: true) != nil
	}

	var links: [CHLink]? {
		get {
			guard let linksDataString = userInfo(forKey: "links"), let data = linksDataString.data(using: .utf8) else {
				return nil
			}
			guard let links = try? JSONDecoder().decode([CHLink].self, from: data) else {
				return nil
			}
			return links
		}
		set {
			guard let links = newValue, let data = try? JSONEncoder().encode(links), let linkDataString = String(data: data, encoding: .utf8) else {
				return
			}
			setUserInfo(string: linkDataString, forKey: "links")
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

extension CHTask {
	var ockTask: OCKAnyTask {
		healthKitLinkage != nil ? OCKHealthKitTask(task: self) : OCKTask(task: self)
	}
}
