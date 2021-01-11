//
//  OCKPatient+CodexResource.swift
//  Alfred
//
//  Created by Waqar Malik on 1/10/21.
//

import CareKitStore
import FirebaseAuth
import Foundation

extension OCKPatient {
	init?(id: String? = nil, resource: CodexResource, user: User?) {
		guard let identifier = id ?? resource.id, let name = resource.name?.first else {
			return nil
		}
		let nameComponents = PersonNameComponents(resourceName: name)
		self.init(id: identifier, name: nameComponents)
		if let birthdate = resource.birthDate {
			self.birthday = DateFormatter.yyyyMMdd.date(from: birthdate)
		}

		if let gender = resource.gender {
			self.sex = OCKBiologicalSex(rawValue: gender) ?? .other(gender)
		}

		let rfcFormatter = DateFormatter.rfc3339
		if let effectiveDate = resource.effectiveDateTime, let date = rfcFormatter.date(from: effectiveDate) {
			self.effectiveDate = date
		}
		if let lastUpdated = resource.meta?.lastUpdated {
			setUserInfo(item: lastUpdated, forKey: "lastUpdated")
		}

		self.versionId = resource.meta?.versionID
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
