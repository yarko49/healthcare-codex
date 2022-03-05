//
//  CarePlan+OCKCarePlan.swift
//  Allie
//
//  Created by Waqar Malik on 1/10/21.
//

import CareKitStore
import Foundation

extension OCKCarePlan: AnyItemDeletable {
	public init(carePlan: CHCarePlan) {
		self.init(id: carePlan.id, title: carePlan.title, patientUUID: UUID(uuidString: carePlan.patientId ?? ""))
		self.timezone = carePlan.timezone
		self.tags = carePlan.tags
		self.source = carePlan.source
		self.userInfo = carePlan.userInfo
		self.asset = carePlan.asset
		if let date = createdDate {
			if date > carePlan.createdDate {
				self.createdDate = carePlan.createdDate
			}
		} else {
			self.createdDate = carePlan.createdDate
		}

		if effectiveDate > carePlan.effectiveDate {
			self.effectiveDate = carePlan.effectiveDate
		}
		self.deletedDate = carePlan.deletedDate
		self.updatedDate = carePlan.updatedDate
	}

	public func merged(newCarePlan: OCKCarePlan) -> Self {
		var existing = self
		existing.title = newCarePlan.title
		existing.groupIdentifier = newCarePlan.groupIdentifier
		existing.tags = newCarePlan.tags
		existing.userInfo = newCarePlan.userInfo
		existing.source = newCarePlan.source
		existing.asset = newCarePlan.asset
		existing.notes = newCarePlan.notes
		existing.timezone = newCarePlan.timezone
		existing.createdDate = newCarePlan.createdDate
		existing.effectiveDate = newCarePlan.effectiveDate
		return existing
	}
}
