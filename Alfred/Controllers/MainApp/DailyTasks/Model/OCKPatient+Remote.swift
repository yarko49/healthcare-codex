//
//  OCKPatient+CodexResource.swift
//  Alfred
//
//  Created by Waqar Malik on 1/10/21.
//

import CareKitStore
import Foundation

extension OCKPatient {
	init?(id: String? = nil, resource: PatientResource, user: RemoteUser?) {
		guard let identifier = id ?? resource.id, let name = resource.nameComponents else {
			return nil
		}
		let nameComponents = PersonNameComponents(resourceName: name)
		self.init(id: identifier, name: nameComponents)
		self.birthday = resource.birthday

		if let gender = resource.gender {
			self.sex = OCKBiologicalSex(rawValue: gender) ?? .other(gender)
		}

		self.effectiveDate = resource.effectiveDate ?? Date()

		if let lastUpdated = resource.lastUpdated {
			setUserInfo(item: lastUpdated, forKey: "lastUpdated")
		}

		self.versionId = resource.versionId
		self.email = user?.email
		self.remoteID = user?.uid
		setUserInfo(item: user?.phoneNumber, forKey: "phoneNumber")
	}

	var email: String? {
		get {
			userInfo?["email"]
		}
		set {
			setUserInfo(item: newValue, forKey: "email")
		}
	}

	var versionId: String? {
		get {
			userInfo?["versionId"]
		}
		set {
			setUserInfo(item: newValue, forKey: "versionId")
		}
	}

	mutating func setUserInfo(item: String?, forKey key: String) {
		var info = userInfo ?? [:]
		if let value = item {
			info[key] = value
			userInfo = info
		} else {
			userInfo?.removeValue(forKey: key)
		}
	}
}
