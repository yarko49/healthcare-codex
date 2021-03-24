//
//  CarePlan+OCKCarePlan.swift
//  Allie
//
//  Created by Waqar Malik on 1/10/21.
//

import CareKitStore
import Foundation

extension CarePlan {
	init(ockCarePlan: OCKCarePlan) {
		self.id = ockCarePlan.id
		self.title = ockCarePlan.title
		self.timezone = ockCarePlan.timezone
		self.remoteId = ockCarePlan.remoteID
		self.groupIdentifier = ockCarePlan.groupIdentifier
		self.effectiveDate = ockCarePlan.effectiveDate
		self.deletedDate = ockCarePlan.deletedDate
		self.asset = ockCarePlan.asset
		self.tags = ockCarePlan.tags
		self.source = ockCarePlan.source
		self.userInfo = ockCarePlan.userInfo?.compactMapValues { (string) -> AnyPrimitiveValue? in
			AnyPrimitiveValue(string)
		}
		self.createdDate = ockCarePlan.createdDate
		self.updatedDate = ockCarePlan.updatedDate
		self.patientId = ockCarePlan.patientUUID?.uuidString
	}
}

extension OCKCarePlan {
	init(carePlan: CarePlan) {
		self.init(id: carePlan.id, title: carePlan.title, patientUUID: UUID(uuidString: carePlan.patientId ?? ""))
		self.timezone = carePlan.timezone
		self.groupIdentifier = carePlan.groupIdentifier
		self.tags = carePlan.tags
		self.source = carePlan.source
		self.userInfo = carePlan.userInfo?.compactMapValues { (value) -> String? in
			value.stringValue
		}
		self.remoteID = carePlan.remoteId
		self.asset = carePlan.asset
		self.effectiveDate = carePlan.effectiveDate
		self.deletedDate = carePlan.deletedDate
		self.createdDate = carePlan.createdDate
		self.updatedDate = carePlan.updatedDate
	}
}
