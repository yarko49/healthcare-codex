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

class RemoteConfigManager: ObservableObject {
	private let remoteConfig = RemoteConfig.remoteConfig()
	@Published var feedbackEmail: String = AppConfig.supportEmail
	@Published var remoteLogging = RemoteLogging()
	@Published var healthCareOrganization: String = "CodexPilotHealthcareOrganization"
	@Published var outcomesUploadTimeInterval: TimeInterval = 5.0

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
					ALog.debug("Unknown Status")
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
					LoggingManager.changeLogger(level: logging.logLevel)
				}
				remoteLogging = logging
			}
		}

		let outcomesUploadInterval = remoteConfig.configValue(forKey: CodingKeys.outcomesUploadTimeInterval.rawValue).numberValue.doubleValue
		outcomesUploadTimeInterval = TimeInterval(max(outcomesUploadInterval, 5.0))
	}

	private enum CodingKeys: String, CodingKey {
		case feedbackEmaail = "feedback_email"
		case remoteLogging = "remote_logging"
		case healthCareOrganization = "health_care_organization"
		case outcomesUploadTimeInterval = "outcomes_upload_time_interval"
	}
}
