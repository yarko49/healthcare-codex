//
//  OCKCDPatient+Allie.swift
//  Allie
//
//  Created by Waqar Malik on 12/7/20.
//

import CareKitStore
import Foundation

extension OCKPatient: AnyItemDeletable {
	public init(patient: CHPatient) {
		self.init(id: patient.id, name: patient.name)
		self.sex = patient.sex
		self.birthday = patient.birthday
		self.allergies = patient.allergies
		if let date = createdDate {
			if date > patient.createdDate {
				self.createdDate = patient.createdDate
			}
		} else {
			self.createdDate = patient.createdDate
		}
		self.effectiveDate = patient.effectiveDate
		self.deletedDate = patient.deletedDate
		self.groupIdentifier = patient.groupIdentifier
		self.tags = patient.tags
		self.remoteID = patient.remoteId
		self.source = patient.source
		self.userInfo = patient.userInfo
		self.asset = patient.asset
		self.timezone = patient.timezone
	}

	public func merged(newPatient: OCKPatient) -> Self {
		var existing = self
		existing.sex = newPatient.sex
		existing.birthday = newPatient.birthday
		existing.allergies = newPatient.allergies
		existing.groupIdentifier = newPatient.groupIdentifier
		existing.tags = newPatient.tags
		existing.remoteID = newPatient.remoteID
		existing.source = newPatient.source
		existing.userInfo = newPatient.userInfo
		existing.asset = newPatient.asset
		existing.timezone = newPatient.timezone
		return existing
	}
}
