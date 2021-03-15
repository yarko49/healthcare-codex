//
//  PersonNameComponents+ResourceName.swift
//  Allie
//
//  Created by Waqar Malik on 1/10/21.
//

import CareKitStore
import Foundation

extension PersonNameComponents {
	init(name: String) {
		var components = name.components(separatedBy: " ")
		self.init()
		self.familyName = components.last
		components.removeLast()
		self.givenName = components.first
		components.removeFirst()
		self.middleName = components.joined(separator: " ")
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
