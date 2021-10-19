//
//  RemoteConfigManager.swift
//  Allie
//
//  Created by Waqar Malik on 1/5/21.
//

import Combine
import FirebaseRemoteConfig
import Foundation

class RemoteConfigManager: ObservableObject {
	private let remoteConfig = RemoteConfig.remoteConfig()
	@Published var feedbackEmail: String = AppConfig.supportEmail
	@Published var remoteLogging = RemoteLoggingConfig()
	@Published var fileLogging = FileLoggingConfig()
	@Published var healthCareOrganization: String = "Demo-Organization-hmbj3"
	@Published var outcomesUploadTimeInterval: TimeInterval = 5.0
	@Published var stepCountUploadEnabled: Bool = false
	@Published var isDebugMenuEnabled: Bool = false
	@Published var minimumSupportedVersion = SupportedVersionConfig()

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
			let logging = RemoteLoggingConfig(dictionary: logging)
			if logging != remoteLogging {
				if logging.logLevel != remoteLogging.logLevel {
					LoggingManager.remoteLogLevel = logging.logLevel
				}
				remoteLogging = logging
			}
		}

		if let logging = remoteConfig.configValue(forKey: CodingKeys.fileLogging.rawValue).jsonValue as? [String: Any] {
			let logging = FileLoggingConfig(dictionary: logging)
			if logging != fileLogging {
				fileLogging = logging
			}
		}

		let outcomesUploadInterval = remoteConfig.configValue(forKey: CodingKeys.outcomesUploadTimeInterval.rawValue).numberValue.doubleValue
		outcomesUploadTimeInterval = TimeInterval(max(outcomesUploadInterval, 5.0))
		stepCountUploadEnabled = remoteConfig.configValue(forKey: CodingKeys.stepCountUploadEnabled.rawValue).boolValue

		if let version = remoteConfig.configValue(forKey: CodingKeys.minimumSupportedVersion.rawValue).jsonValue as? [String: Any] {
			guard let versionString = version["version"] as? String, let buildString = version["build"] as? String else {
				return
			}
			guard let osv = OperatingSystemVersion(versionString), let buildNumber = Int(buildString) else {
				return
			}
			var date = Date()
			if let dateString = version["date"] as? String {
				date = DateFormatter.wholeDate.date(from: dateString) ?? Date()
			}
			let message = version["message"] as? String
			let applicationVersion = ApplicationVersion(operatingSystemVersion: osv, buildNumber: buildNumber)
			minimumSupportedVersion = SupportedVersionConfig(version: applicationVersion, date: date, message: message)
		}
	}

	private enum CodingKeys: String, CodingKey {
		case feedbackEmaail = "feedback_email"
		case remoteLogging = "remote_logging"
		case fileLogging = "file_logging"
		case healthCareOrganization = "health_care_organization"
		case outcomesUploadTimeInterval = "outcomes_upload_time_interval"
		case stepCountUploadEnabled = "step_count_upload_enabled"
		case isDebugMenuEnabled = "debug_menu_enabled"
		case minimumSupportedVersion = "minimum_supported_version"
	}
}
