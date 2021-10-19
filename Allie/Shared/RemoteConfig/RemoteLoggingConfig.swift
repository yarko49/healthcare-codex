//
//  RemoteLogging.swift
//  Allie
//
//  Created by Waqar Malik on 10/13/21.
//

import Foundation

struct RemoteLoggingConfig: Codable, Hashable {
	let isEnabled: Bool
	let minimumLevel: String

	private static let defaultMinimumLevel = "error"
	private enum CodingKeys: String, CodingKey {
		case isEnabled = "enabled"
		case minimumLevel = "minimum_level"
	}

	init() {
		self.isEnabled = true
		self.minimumLevel = RemoteLoggingConfig.defaultMinimumLevel
	}

	init(dictionary: [String: Any]) {
		let enabled = dictionary[CodingKeys.isEnabled.rawValue] as? Bool ?? true
		self.isEnabled = enabled
		let level = dictionary[CodingKeys.minimumLevel.rawValue] as? String ?? RemoteLoggingConfig.defaultMinimumLevel
		self.minimumLevel = level
	}
}
