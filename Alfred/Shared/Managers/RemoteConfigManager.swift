//
//  RemoteConfigManager.swift
//  Alfred
//
//  Created by Waqar Malik on 1/5/21.
//

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
	@Published var feedbackEmail: String = "support@codexhealth.com"
	@Published var remoteLogging = RemoteLogging()

	func refresh() {
		let settings = RemoteConfigSettings()
		settings.minimumFetchInterval = 0
		remoteConfig.configSettings = settings
		remoteConfig.fetchAndActivate { [weak self] activateStatus, error in
			switch activateStatus {
			case .error:
				ALog.error("Could not fetch config  \(error?.localizedDescription ?? "No error available.")")
			case .successFetchedFromRemote, .successUsingPreFetchedData:
				self?.updatecProperties()
			@unknown default:
				ALog.debug("Unknown Status")
			}
		}
	}

	private func updatecProperties() {
		if let email = remoteConfig.configValue(forKey: CodingKeys.feedbackEmaail.rawValue).stringValue {
			feedbackEmail = email
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
	}

	private enum CodingKeys: String, CodingKey {
		case feedbackEmaail = "feedback_email"
		case remoteLogging = "remote_logging"
	}
}
