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
		if let name = user?.displayName {
			nameComponents = PersonNameComponents(name: name)
		}
		self.init(id: identifier, name: nameComponents)
	}
}

extension AlliePatient {
	init?(user: RemoteUser?) {
		guard let identifier = user?.uid else {
			return nil
		}
		var nameComponents = PersonNameComponents()
		if let name = user?.displayName {
			nameComponents = PersonNameComponents(name: name)
		}
		self.init(id: identifier, name: nameComponents)
		profile.deviceManufacturer = "Apple"
		profile.deviceSoftwareVersion = UIDevice.current.systemVersion
	}
}
