//
//  RemoteConfigManager.swift
//  Allie
//
//  Created by Waqar Malik on 1/5/21.
//

import Combine
import FirebaseRemoteConfig
import Foundation

struct RemoteLogging: Codable, Hashable {
	let isEnabled: Bool
	let minimumLevel: String
	private static let defaultMinimumLevel = "error"
	private enum CodingKeys: String, CodingKey {
		case isEnabled = "enabled"
		case minimumLevel = "minimum_level"
	}

	init() {
		self.isEnabled = true
		self.minimumLevel = RemoteLogging.defaultMinimumLevel
	}

	init(dictionary: [String: Any]) {
		let enabled = dictionary[CodingKeys.isEnabled.rawValue] as? Bool ?? true
		self.isEnabled = enabled
		let level = dictionary[CodingKeys.minimumLevel.rawValue] as? String ?? RemoteLogging.defaultMinimumLevel
		self.minimumLevel = level
	}
}

struct FileLogging: Codable, Hashable {
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
		self.minimumLevel = FileLogging.defaultMinimumLevel
		self.fileName = "Allie.log"
	}

	init(dictionary: [String: Any]) {
		let enabled = dictionary[CodingKeys.isEnabled.rawValue] as? Bool ?? true
		self.isEnabled = enabled
		let level = dictionary[CodingKeys.minimumLevel.rawValue] as? String ?? FileLogging.defaultMinimumLevel
		self.minimumLevel = level
		self.fileName = dictionary[CodingKeys.fileName.rawValue] as? String ?? "Allie.log"
	}
}

class RemoteConfigManager: ObservableObject {
	static let shared = RemoteConfigManager()
	private let remoteConfig = RemoteConfig.remoteConfig()
	@Published var feedbackEmail: String = AppConfig.supportEmail
	@Published var remoteLogging = RemoteLogging()
	@Published var fileLogging = FileLogging()
	@Published var healthCareOrganization: String = "Demo-Organization-hmbj3"
	@Published var outcomesUploadTimeInterval: TimeInterval = 5.0
	@Published var stepCountUploadEnabled: Bool = false
	@Published var isDebugMenuEnabled: Bool = false

	func refresh() -> Future<Bool, Never> {
		Future { [weak self] promise in
			let settings = RemoteConfigSettings()
			settings.minimumFetchInterval = 0
			self?.remoteConfig.configSettings = settings
			self?.remoteConfig.fetchAndActivate { [weak self] activateStatus, error in
				switch activateStatus {
				case .error:
					ALog.error("Could not fetch config", error: error)
					promise(.success(false))
				case .successFetchedFromRemote, .successUsingPreFetchedData:
					self?.updateProperties()
					promise(.success(true))
				@unknown default:
					ALog.info("Unknown Status")
					promise(.success(false))
				}
			}
		}
	}

	private func updateProperties() {
		if let email = remoteConfig.configValue(forKey: CodingKeys.feedbackEmaail.rawValue).stringValue {
			feedbackEmail = email
		}

		if let organization = remoteConfig.configValue(forKey: CodingKeys.healthCareOrganization.rawValue).stringValue {
			healthCareOrganization = organization
		}

		if let logging = remoteConfig.configValue(forKey: CodingKeys.remoteLogging.rawValue).jsonValue as? [String: Any] {
			let logging = RemoteLogging(dictionary: logging)
			if logging != remoteLogging {
				if logging.logLevel != remoteLogging.logLevel {
					LoggingManager.remoteLogLevel = logging.logLevel
				}
				remoteLogging = logging
			}
		}

		if let logging = remoteConfig.configValue(forKey: CodingKeys.fileLogging.rawValue).jsonValue as? [String: Any] {
			let logging = FileLogging(dictionary: logging)
			if logging != fileLogging {
				if logging.logLevel != fileLogging.logLevel {
					LoggingManager.fileLogLevel = logging.logLevel
				}
				fileLogging = logging
			}
		}

		let outcomesUploadInterval = remoteConfig.configValue(forKey: CodingKeys.outcomesUploadTimeInterval.rawValue).numberValue.doubleValue
		outcomesUploadTimeInterval = TimeInterval(max(outcomesUploadInterval, 5.0))
		stepCountUploadEnabled = remoteConfig.configValue(forKey: CodingKeys.stepCountUploadEnabled.rawValue).boolValue
	}

	private enum CodingKeys: String, CodingKey {
		case feedbackEmaail = "feedback_email"
		case remoteLogging = "remote_logging"
		case fileLogging = "file_logging"
		case healthCareOrganization = "health_care_organization"
		case outcomesUploadTimeInterval = "outcomes_upload_time_interval"
		case stepCountUploadEnabled = "step_count_upload_enabled"
		case isDebugMenuEnabled = "debug_menu_enabled"
	}
}
