//
//  SupportedVersionConfig.swift
//  Allie
//
//  Created by Waqar Malik on 10/13/21.
//

import Foundation

struct SupportedVersionConfig: Codable, Hashable {
	let version: ApplicationVersion
	let date: Date?
	let message: String?

	init() {
		self.version = ApplicationVersion.current!
		self.date = Date()
		self.message = ""
	}

	init(version: ApplicationVersion, date: Date? = nil, message: String? = nil) {
		self.version = version
		self.date = date
		self.message = message
	}
}
