//
//  OCKCDPatient+Allie.swift
//  Allie
//
//  Created by Waqar Malik on 12/7/20.
//

import CareKitStore
import Foundation

extension OCKPatient {
	init(patient: AlliePatient) {
		self.init(id: patient.id, name: patient.name)
		self.sex = patient.sex
		self.birthday = patient.birthday
		self.allergies = patient.allergies
		self.effectiveDate = patient.effectiveDate
		self.groupIdentifier = patient.groupIdentifier
		self.tags = patient.tags
		self.remoteID = patient.remoteID
		self.source = patient.source
		self.userInfo = patient.userInfo
		self.asset = patient.asset
		self.timezone = patient.timezone
	}

	var alliePatient: AlliePatient {
		AlliePatient(ockPatient: self)
	}

	func merged(newPatient: OCKPatient) -> Self {
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
		existing.deletedDate = newPatient.deletedDate
		return existing
	}
}

extension AlliePatient {
	init(ockPatient: OCKPatient) {
		self.init(id: ockPatient.id, name: ockPatient.name)
		self.sex = ockPatient.sex
		self.birthday = ockPatient.birthday
		self.allergies = ockPatient.allergies
		self.createdDate = ockPatient.createdDate
		self.updatedDate = ockPatient.updatedDate
		self.effectiveDate = ockPatient.effectiveDate
		self.groupIdentifier = ockPatient.groupIdentifier
		self.tags = ockPatient.tags
		self.remoteID = ockPatient.remoteID
		self.source = ockPatient.source
		self.userInfo = ockPatient.userInfo
		self.asset = ockPatient.asset
		self.timezone = ockPatient.timezone
	}

	var ockPatient: OCKPatient {
		OCKPatient(patient: self)
	}
}
