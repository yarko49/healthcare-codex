//
//  FirebaseUser+Patient.swift
//  Allie
//
//  Created by Waqar Malik on 1/12/21.
//

import CareKitStore
import FirebaseAuth
import UIKit

protocol RemoteUser {
	var uid: String { get }
	var email: String? { get }
	var phoneNumber: String? { get }
	var displayName: String? { get }
}

extension User: RemoteUser {}

extension OCKPatient {
	init?(user: RemoteUser?) {
		guard let identifier = user?.uid else {
			return nil
		}
		var nameComponents = PersonNameComponents()
		if let name = PersonNameComponents(fullName: user?.displayName) {
			nameComponents = name
		}
		self.init(id: identifier, name: nameComponents)
		createdDate = Date()
		updatedDate = Date()
		timezone = .current
	}
}

extension AlliePatient {
	init?(user: RemoteUser?) {
		guard let identifier = user?.uid else {
			return nil
		}
		var nameComponents = PersonNameComponents()
		if let name = PersonNameComponents(fullName: user?.displayName) {
			nameComponents = name
		}
		self.init(id: identifier, name: nameComponents)
		profile.email = user?.email
		profile.phoneNumber = user?.phoneNumber
		profile.deviceManufacturer = "Apple"
		profile.deviceSoftwareVersion = UIDevice.current.systemVersion
		createdDate = Date()
		updatedDate = Date()
		effectiveDate = Date()
		timezone = .current
	}
}
