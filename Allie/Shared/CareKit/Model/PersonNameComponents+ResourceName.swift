//
//  PersonNameComponents+ResourceName.swift
//  Allie
//
//  Created by Waqar Malik on 1/10/21.
//

import CareKitStore
import Foundation

extension PersonNameComponents {
	init?(fullName: String?) {
		guard let name = fullName else {
			return nil
		}
		var components = name.components(separatedBy: " ")
		guard !components.isEmpty else {
			return nil
		}
		self.init()
		givenName = components.first
		components.removeFirst()
		familyName = components.last
		components.removeLast()
		middleName = components.joined(separator: " ")
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
		if let value = familyName {
			names.append(value)
		}
		if let value = nameSuffix {
			names.append(value)
		}

		return names.isEmpty ? nil : names.joined(separator: " ")
	}
}
