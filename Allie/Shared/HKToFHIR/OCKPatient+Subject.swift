//
//  OCKPatient+Subject.swift
//  Allie
//
//  Created by Waqar Malik on 3/12/21.
//

import CareKitStore
import Foundation
import ModelsR4

extension OCKPatient {
	var subject: ModelsR4.Reference? {
		let subject = ModelsR4.Reference()
		if let identifier = remoteID {
			subject.identifier = BaseFactory.identifier(system: BaseFactory.healthKitIdentifierSystemKey, value: identifier)
		}

		if let name = self.name.fullName {
			subject.display = FHIRPrimitive<FHIRString>(stringLiteral: name)
		}
		return subject
	}
}

extension CHPatient {
	var subject: ModelsR4.Reference? {
		let subject = ModelsR4.Reference()
		if let identifier = profile.fhirId {
			subject.identifier = BaseFactory.identifier(system: BaseFactory.healthKitIdentifierSystemKey, value: identifier)
		}

		if let name = self.name.fullName {
			subject.display = FHIRPrimitive<FHIRString>(stringLiteral: name)
		}
		return subject
	}
}
