//
//  OCKCDPatient+Allie.swift
//  Allie
//
//  Created by Waqar Malik on 12/7/20.
//

import CareKitStore
import Foundation

extension OCKPatient {
	init(patient: Patient) {
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
		self.notes = patient.notes?.compactMap { (note) -> OCKNote? in
			OCKNote(note: note)
		}
		self.timezone = patient.timezone
	}

	static var sample: OCKPatient {
		var name = PersonNameComponents()
		name.familyName = "Pavlov"
		name.givenName = "Ivan"
		name.middleName = "Petrovich"
		name.namePrefix = "Dr."
		let id = "ivanpavlov"
		var patient = OCKPatient(id: id, name: name)
		patient.sex = .male
		patient.birthday = DateFormatter.yyyyMMdd.date(from: "1849-09-26")
		patient.effectiveDate = Date()
		return patient
	}
}

extension Patient {
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
		self.notes = ockPatient.notes?.compactMap { (ockNote) -> Note? in
			Note(ockNote: ockNote)
		}
		self.timezone = ockPatient.timezone
	}
}
