//
//  OCKCDPatient+Allie.swift
//  Allie
//
//  Created by Waqar Malik on 12/7/20.
//

import CareKitStore
import Foundation

extension AlliePatient {
	var uuid: UUID? {
		guard let id = FHIRId else {
			return nil
		}
		return UUID(uuidString: id)
	}
}

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
		if let uuid = patient.uuid {
			self.uuid = uuid
		}
	}

	var alliePatient: AlliePatient {
		AlliePatient(ockPatient: self)
	}

	mutating func update(newPatient: OCKPatient) {
		sex = newPatient.sex
		birthday = newPatient.birthday
		allergies = newPatient.allergies
		effectiveDate = newPatient.effectiveDate
		groupIdentifier = newPatient.groupIdentifier
		tags = newPatient.tags
		remoteID = newPatient.remoteID
		source = newPatient.source
		userInfo = newPatient.userInfo
		asset = newPatient.asset
		timezone = newPatient.timezone
		deletedDate = newPatient.deletedDate
		uuid = newPatient.uuid
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
