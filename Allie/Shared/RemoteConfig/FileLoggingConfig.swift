//
//  FileLogging.swift
//  Allie
//
//  Created by Waqar Malik on 10/13/21.
//

import Foundation

struct FileLoggingConfig: Codable, Hashable {
	let isEnabled: Bool
	let minimumLevel: String
	let fileName: String

	private static let defaultMinimumLevel = "error"
	private enum CodingKeys: String, CodingKey {
		case isEnabled = "enabled"
		case minimumLevel = "minimum_level"
		case fileName = "filename"
	}

	init() {
		self.isEnabled = true
		self.minimumLevel = FileLoggingConfig.defaultMinimumLevel
		self.fileName = "Allie.log"
	}

	init(dictionary: [String: Any]) {
		let enabled = dictionary[CodingKeys.isEnabled.rawValue] as? Bool ?? true
		self.isEnabled = enabled
		let level = dictionary[CodingKeys.minimumLevel.rawValue] as? String ?? FileLoggingConfig.defaultMinimumLevel
		self.minimumLevel = level
		self.fileName = dictionary[CodingKeys.fileName.rawValue] as? String ?? "Allie.log"
	}
}
