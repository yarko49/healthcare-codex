//
//  CarePlan+OCKCarePlan.swift
//  Alfred
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
		self.patientId = ockCarePlan.patientUUID?.uuidString ?? ""
		self.remoteId = ockCarePlan.remoteID
		self.groupIdentifier = ockCarePlan.groupIdentifier
		self.effectiveDate = ockCarePlan.effectiveDate
		self.asset = ockCarePlan.asset
		self.tags = ockCarePlan.tags
		self.source = ockCarePlan.source
		self.userInfo = ockCarePlan.userInfo
		self.notes = ockCarePlan.notes?.reduce(into: [:]) { result, ockNote in
			let note = Note(ockNote: ockNote)
			if let id = note.id {
				result?[id] = note
			}
		}
		self.tasks = nil
	}
}

extension OCKCarePlan {
	init(carePlan: CarePlan) {
		self.init(id: carePlan.id, title: carePlan.title, patientUUID: nil)
		self.timezone = carePlan.timezone
		self.groupIdentifier = carePlan.groupIdentifier
		self.tags = carePlan.tags
		self.source = carePlan.source
		self.userInfo = carePlan.userInfo
		self.remoteID = carePlan.remoteId
		self.asset = carePlan.asset
		self.notes = carePlan.notes?.values.map { (note) -> OCKNote in
			OCKNote(note: note)
		}
	}
}
