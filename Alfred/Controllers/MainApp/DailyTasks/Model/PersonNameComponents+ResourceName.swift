//
//  PersonNameComponents+ResourceName.swift
//  Alfred
//
//  Created by Waqar Malik on 1/10/21.
//

import CareKitStore
import Foundation

extension PersonNameComponents {
	init(resourceName: ResourceName) {
		self.init()
		var givenNames = resourceName.given
		self.familyName = resourceName.family
		self.givenName = givenNames?.first
		givenNames?.removeFirst()
		if givenNames?.isEmpty == false {
			self.middleName = givenNames?.joined(separator: " ")
		}
	}

	var fullName: String? {
		var names: [String] = []
		if let value = namePrefix {
			names.append(value)
		}
		if let value = givenName {
			names.append(value)
		}
		if let value = middleName {
			names.append(value)
		}
		if let value = nameSuffix {
			names.append(value)
		}

		return names.isEmpty ? nil : names.joined(separator: " ")
	}
}
