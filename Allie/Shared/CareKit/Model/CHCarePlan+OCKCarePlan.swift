//
//  CarePlan+OCKCarePlan.swift
//  Allie
//
//  Created by Waqar Malik on 1/10/21.
//

import CareKitStore
import Foundation

extension OCKCarePlan: AnyItemDeletable {
	init(carePlan: CHCarePlan) {
		self.init(id: carePlan.id, title: carePlan.title, patientUUID: UUID(uuidString: carePlan.patientId ?? ""))
		self.timezone = carePlan.timezone
		self.tags = carePlan.tags
		self.source = carePlan.source
		self.userInfo = carePlan.userInfo
		self.asset = carePlan.asset
		self.effectiveDate = carePlan.effectiveDate
		self.deletedDate = carePlan.deletedDate
		self.createdDate = carePlan.createdDate
		self.updatedDate = carePlan.updatedDate
	}

	func merged(newCarePlan: OCKCarePlan) -> Self {
		var existing = self
		existing.title = newCarePlan.title
		existing.deletedDate = newCarePlan.deletedDate
		existing.groupIdentifier = newCarePlan.groupIdentifier
		existing.tags = newCarePlan.tags
		existing.userInfo = newCarePlan.userInfo
		existing.source = newCarePlan.source
		existing.asset = newCarePlan.asset
		existing.notes = newCarePlan.notes
		existing.timezone = newCarePlan.timezone
		return existing
	}
}
